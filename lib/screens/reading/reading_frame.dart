import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:podo/common/ads_controller.dart';
import 'package:podo/common/cloud_storage.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/flashcard_icon.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/common/history.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/screens/reading/reading.dart';
import 'package:podo/screens/reading/reading_controller.dart';
import 'package:podo/screens/reading/reading_title.dart';
import 'package:podo/values/my_colors.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReadingFrame extends StatefulWidget {
  const ReadingFrame({Key? key}) : super(key: key);

  @override
  _ReadingFrameState createState() => _ReadingFrameState();
}

class _ReadingFrameState extends State<ReadingFrame> with TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  double sliverAppBarHeight = 200.0;
  double sliverAppBarStretchOffset = 100.0;
  ReadingTitle readingTitle = Get.arguments;
  String fo = User().language;
  final KO = 'ko';
  final AUDIO = 'audio';
  final cardBorderRadius = 8.0;
  bool isImageVisible = true;
  late AnimationController animationController;
  late Animation<double> animation;
  double currentScrollPercent = 0;
  double scrollPosition = 0;
  late List<Reading> readings;
  late Future future;
  final controller = Get.find<ReadingController>();
  late bool isLoading;
  late double progressValue;
  Map<String, String> audioPaths = {};

  @override
  void dispose() {
    super.dispose();
    if (currentScrollPercent > 0.1 && currentScrollPercent < 0.9) {
      LocalStorage().prefs!.setDouble(readingTitle.id, scrollPosition);
    } else {
      LocalStorage().prefs!.remove(readingTitle.id);
    }
    scrollController.dispose();
    PlayAudio().reset();
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    readings = [];
    progressValue = 0.0;

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    animation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    ));
    scrollController.addListener(() => setState(() {
          if (scrollController.offset <= 50) {
            if (animationController.value == 1) {
              animationController.reverse();
            }
          } else {
            if (animationController.value == 0) {
              animationController.forward();
            }
          }
          double maxScroll = scrollController.position.maxScrollExtent;
          scrollPosition = scrollController.position.pixels;
          currentScrollPercent = scrollPosition / maxScroll;
          if (currentScrollPercent <= 0) {
            currentScrollPercent = 0;
          }
          if (currentScrollPercent >= 1) {
            currentScrollPercent = 1;
          }
        }));

    final Query query =
        FirebaseFirestore.instance.collection('ReadingTitles/${readingTitle.id}/Readings').orderBy('orderId');
    Future.wait([
      Database().getDocs(query: query),
      CloudStorage().downloadAudios(folderName: 'ReadingAudios', folderId: readingTitle.id),
    ]).then((snapshots) async {
      int totalReadings = snapshots[0].length;
      double incrementPerReading = 0.2 / totalReadings;
      controller.hasFlashcard.value = {};
      for (dynamic snapshot in snapshots[0]) {
        Reading reading = Reading.fromJson(snapshot.data() as Map<String, dynamic>);
        readings.add(reading);
        progressValue += incrementPerReading;
        controller.hasFlashcard[reading.id] = LocalStorage().hasFlashcard(itemId: reading.id);
        setState(() {});
      }
      controller.initIsExpanded(readings.length);

      Map<String, String> audios = {};
      for (dynamic snapshot in snapshots[1]) {
        audios.addAll(snapshot);
      }
      await cacheFiles(audios);
      setState(() {
        isLoading = false;
      });
    });

    double? position = LocalStorage().prefs!.getDouble(readingTitle.id);
    if (position != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.dialog(AlertDialog(
          title: Text(tr('continueReading')),
          actions: [
            TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text(tr('no'), style: const TextStyle(color: MyColors.navy))),
            TextButton(
                onPressed: () {
                  Get.back();
                  scrollController.animateTo(position,
                      duration: const Duration(milliseconds: 500), curve: Curves.ease);
                },
                child: Text(tr('yes'), style: const TextStyle(color: MyColors.purple))),
          ],
        ));
      });
    }
  }

  Future<void> cacheFiles(Map<String, String> snapshots) async {
    final directory = await getTemporaryDirectory();
    audioPaths = {};
    double incrementPerFile = 0.8 / snapshots.length;

    for (var fileName in snapshots.keys) {
      final url = snapshots[fileName];
      final response = await http.get(Uri.parse(url!));
      final File file = File('${directory.path}/$fileName.m4a');
      await file.writeAsBytes(response.bodyBytes);
      audioPaths[fileName] = file.path;
      progressValue += incrementPerFile;
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (User().status == 1) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    final AnchoredAdaptiveBannerAdSize? size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());
    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }
    AdsController().loadBannerAd(size);
  }

  Widget letterContainer(String text) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white,
            width: 2,
          )),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  sliverAppBar() {
    int wordsLength = 0;
    for (Reading reading in readings) {
      if (reading.words[KO] != null) {
        int length = reading.words[KO].length;
        wordsLength = wordsLength + length;
      }
    }

    return SliverAppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        color: Colors.white,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      expandedHeight: sliverAppBarHeight,
      collapsedHeight: 60,
      pinned: true,
      stretch: true,
      title: MyWidget().getTextWidget(
        text: '${readingTitle.title[KO]}',
        size: 18,
        color: Colors.white,
        isBold: true,
      ),
      flexibleSpace: Stack(
        children: [
          Container(
            color: MyColors.navyLight,
          ),
          Positioned(
            top: 0,
            right: -30,
            child: Hero(
              tag: 'readingImage:${readingTitle.id}',
              child: FadeTransition(
                opacity: animation,
                child: Image.memory(base64Decode(readingTitle.image!), width: 250, gaplessPlayback: true),
              ),
            ),
          ),
          Opacity(
            opacity: 0.2,
            child: Container(
              color: Colors.black,
            ),
          ),
          LinearProgressIndicator(
            value: currentScrollPercent,
            color: MyColors.purple,
            backgroundColor: MyColors.purpleLight,
          ),
          FadeTransition(
            opacity: animation,
            child: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  letterContainer('S'),
                  const SizedBox(width: 10),
                  Text('${readings.length}'),
                  const SizedBox(width: 20),
                  const Text('|'),
                  const SizedBox(width: 20),
                  letterContainer('V'),
                  const SizedBox(width: 10),
                  Text('$wordsLength'),
                ],
              ),
              expandedTitleScale: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  sliverList() {
    int length = readings.length;
    return SliverPadding(
      padding: const EdgeInsets.all(10),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Column(
              children: [
                partContentKo(index),
                const SizedBox(height: 30),
                partWords(index),
                const SizedBox(height: 30),
                partContentFo(index),
                Obx(() {
                  return controller.getIsExpanded(index) ? const SizedBox.shrink() : const Divider();
                }),
                const SizedBox(height: 30),
                index == length - 1
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: MyWidget().getRoundBtnWidget(
                            text: tr('complete'),
                            f: () {
                              History().addHistory(item: 'reading', itemId: readingTitle.id);
                              LocalStorage().prefs!.remove(readingTitle.id);
                              controller.isCompleted[readingTitle.id] = true;
                              Get.back();
                            }),
                      )
                    : const SizedBox.shrink(),
              ],
            );
          },
          childCount: length,
        ),
      ),
    );
  }

  Widget partContentKo(int index) {
    Reading reading = readings[index];
    final contentKo = reading.content[KO];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: MyWidget().getTextWidget(text: (index + 1).toString(), color: MyColors.purple, isBold: true),
            )),
            Obx(() => FlashcardIcon().getIconButton(
                controller: controller,
                itemId: reading.id,
                front: reading.content[KO],
                back: reading.content[fo],
                audio: 'ReadingAudios_${readingTitle.id}_${reading.id}')),
            Material(
              child: IconButton(
                icon: const Icon(Icons.volume_up_outlined, color: MyColors.purple, size: 28),
                onPressed: () async {
                  PlayAudio().player.stop();
                  String fileName = reading.id;
                  if (audioPaths.containsKey(fileName)) {
                    String path = audioPaths[fileName]!;
                    PlayAudio().player.setFilePath(path);
                    await PlayAudio().player.setVolume(1);
                    PlayAudio().player.play();
                  }
                },
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: MyWidget().getTextWidget(text: contentKo, size: 18, height: 1.8, isKorean: true),
        ),
      ],
    );
  }

  Widget partContentFo(int index) {
    final contentFo = readings[index].content[fo];
    return ExpansionTile(
      onExpansionChanged: (value) {
        controller.setIsExpanded(index, value);
      },
      leading: const Icon(FontAwesomeIcons.language),
      iconColor: MyColors.purple,
      title: const Text(''),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        MyWidget().getTextWidget(text: contentFo, color: MyColors.grey),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget partWords(int index) {
    Reading reading = readings[index];
    List<dynamic> wordKoList = reading.words[KO] ?? [];
    List<dynamic> wordFoList = reading.words[fo] ?? [];

    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: wordKoList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const SizedBox(
                  height: 10,
                  child: VerticalDivider(
                    color: MyColors.purple,
                    thickness: 1,
                    width: 18,
                  ),
                ),
                MyWidget().getTextWidget(text: wordKoList[index], isKorean: true, size: 18),
                const Text(' : '),
                MyWidget().getTextWidget(text: wordFoList[index])
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? MyWidget().getLoading(progressValue)
          : SafeArea(
              child: Container(
                color: MyColors.purpleLight,
                child: readings.isEmpty
                    ? Center(
                        child: MyWidget().getTextWidget(
                          text: tr('noReading'),
                          color: MyColors.purple,
                          size: 20,
                          isTextAlignCenter: true,
                        ),
                      )
                    : Stack(
                        children: [
                          CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            controller: scrollController,
                            slivers: [
                              sliverAppBar(),
                              sliverList(),
                            ],
                          ),
                          User().status == 1
                              ? Positioned(
                                  bottom: 0,
                                  child: GetBuilder<AdsController>(
                                    builder: (_) {
                                      return AdsController().isBannerAdLoaded
                                          ? Container(
                                              color: MyColors.purpleLight,
                                              width: AdsController().bannerAd!.size.width.toDouble(),
                                              height: AdsController().bannerAd!.size.height.toDouble(),
                                              child: AdWidget(ad: AdsController().bannerAd!),
                                            )
                                          : const SizedBox.shrink();
                                    },
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
              ),
            ),
    );
  }
}
