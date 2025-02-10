import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podo/common/ads_controller.dart';
import 'package:podo/common/cloud_storage.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/favorite_icon.dart';
import 'package:podo/common/history.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_tutorial.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_Stop_icon.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/screens/reading/reading.dart';
import 'package:podo/screens/reading/reading_controller.dart';
import 'package:podo/screens/reading/reading_title.dart';
import 'package:podo/values/my_colors.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ReadingFrame extends StatefulWidget {
  const ReadingFrame({Key? key}) : super(key: key);

  @override
  _ReadingFrameState createState() => _ReadingFrameState();
}

class _ReadingFrameState extends State<ReadingFrame> with TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  double sliverAppBarHeight = 200.0;
  double sliverAppBarStretchOffset = 100.0;
  String readingTitleId = Get.arguments;
  late ReadingTitle readingTitle;
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
  late ResponsiveSize rs;
  Map<String, PlayStopIcon> playStopIcons = {};

  MyTutorial? myTutorial;
  GlobalKey? keySaveReading;
  GlobalKey? keySentence;
  GlobalKey? keyFlashcard;
  GlobalKey? keyAudio;
  GlobalKey? keyTranslate;

  @override
  void dispose() {
    scrollController.dispose();
    animationController.dispose();
    AdsController().bannerAd?.dispose();
    PlayAudio().reset();
    super.dispose();
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
        FirebaseFirestore.instance.collection('ReadingTitles/$readingTitleId/Readings').orderBy('orderId');
    Future.wait([
      Database().getDoc(collection: 'ReadingTitles', docId: readingTitleId),
      Database().getDocs(query: query),
      CloudStorage().downloadAudios(folderName: 'ReadingAudios', folderId: readingTitleId),
      Database().getDoc(collection: 'Users/${User().id}/Readings', docId: readingTitleId),
    ]).then((snapshots) async {
      readingTitle = ReadingTitle.fromJson(snapshots[0].data() as Map<String,dynamic>);
      await FirebaseAnalytics.instance.logSelectContent(contentType: 'reading', itemId: readingTitle.title[KO]);
      int totalReadings = snapshots[1].length;
      double incrementPerReading = 0.2 / totalReadings;
      controller.hasFlashcard.value = {};
      for (dynamic snapshot in snapshots[1]) {
        Reading reading = Reading.fromJson(snapshot.data() as Map<String, dynamic>);
        readings.add(reading);
        progressValue += incrementPerReading;
        controller.hasFlashcard[reading.id] = LocalStorage().hasFlashcard(itemId: reading.id);
        if(mounted) {
          playStopIcons[reading.id] = PlayStopIcon(rs, this);
          setState(() {});
        }
      }
      controller.initIsExpanded(readings.length);

      Map<String, String> audios = {};
      for (dynamic snapshot in snapshots[2]) {
        audios.addAll(snapshot);
      }
      await cacheFiles(audios);
      if(mounted) {
        setState(() {
          isLoading = false;
        });
      }
      controller.hasFavoriteReading.value = snapshots[3].exists;
    });
  }

  void setPlayStopIcon(int index, {required bool isForward}) {
    Reading reading = readings[index];
    if (isForward) {
      playStopIcons[reading.id]!.clickIcon(isForward: true);
      reading.isPlay = true;
    } else {
      playStopIcons[reading.id]!.clickIcon(isForward: false);
      reading.isPlay = false;
    }
  }

  Future<void> cacheFiles(Map<String, String> snapshots) async {
    final directory = await getTemporaryDirectory();
    audioPaths = {};
    double incrementPerFile = 0.8 / snapshots.length;

    for (var fileName in snapshots.keys) {
      final url = snapshots[fileName];
      FirebaseCrashlytics.instance.log('Error occurred in cacheFiles()');
      FirebaseCrashlytics.instance.setCustomKey('fileName', fileName);
      FirebaseCrashlytics.instance.setCustomKey('snapshots', snapshots.toString());

      final response = await http.get(Uri.parse(url!));
      final File file = File('${directory.path}/$fileName.m4a');
      await file.writeAsBytes(response.bodyBytes);
      audioPaths[fileName] = file.path;
      progressValue += incrementPerFile;
      if (mounted) {
        setState(() {});
      }
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

  sliverAppBar() {
    return SliverAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, size: rs.getSize(20)),
        color: Colors.white,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      expandedHeight: rs.getSize(sliverAppBarHeight),
      collapsedHeight: rs.getSize(60),
      pinned: true,
      stretch: true,
      title: Row(
        children: [
          Expanded(
            child: MyWidget().getTextWidget(
              rs,
              text: '${readingTitle.title[KO]}',
              size: 18,
              color: Colors.white,
              isBold: true,
            ),
          ),
          Obx(() => FavoriteIcon().getFavoriteReadingIcon(key: keySaveReading, context, rs, item: readingTitle))
        ],
      ),
      flexibleSpace: Stack(
        children: [
          Container(
            color: Theme.of(context).primaryColorLight,
          ),
          readingTitle.image != null && readingTitle.image!.isNotEmpty
              ? Positioned(
                  top: 0,
                  right: -30,
                  child: Hero(
                    tag: 'readingImage:${readingTitle.id}',
                    child: FadeTransition(
                      opacity: animation,
                      child: Image.memory(base64Decode(readingTitle.image!),
                          width: rs.getSize(250), gaplessPlayback: true),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          Opacity(
            opacity: 0.2,
            child: Container(
              color: Theme.of(context).secondaryHeaderColor,
            ),
          ),
          LinearProgressIndicator(
            value: currentScrollPercent,
            color: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          readingTitle.summary != null ?
          FadeTransition(
            opacity: animation,
            child: FlexibleSpaceBar(
              title: MyWidget().getTextWidget(rs, text: readingTitle.summary![fo], color: Colors.white),
              expandedTitleScale: 1.0,
            ),
          ) : const SizedBox.shrink(),
        ],
      ),
    );
  }

  sliverList() {
    int length = readings.length;
    return SliverPadding(
      padding: EdgeInsets.all(rs.getSize(10)),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Column(
              children: [
                partContentKo(index),
                SizedBox(height: rs.getSize(30)),
                partWords(index),
                SizedBox(height: rs.getSize(30)),
                partContentFo(index),
                Obx(() {
                  return controller.getIsExpanded(index) ? const SizedBox.shrink() : const Divider();
                }),
                SizedBox(height: rs.getSize(30)),
                index == length - 1
                    ? Padding(
                        padding: EdgeInsets.only(bottom: rs.getSize(100)),
                        child: MyWidget().getRoundBtnWidget(rs, text: tr('complete'), f: () {
                          History().addHistory(itemIndex: 1, itemId: readingTitle.id, content: readingTitle.title['ko']);
                          //뭔지 몰라서 남겨둠. 이상 없는지 확인 후 삭제
                          //LocalStorage().prefs!.remove(readingTitle.id);
                          controller.isCompleted[readingTitle.id] = true;
                          Get.back();
                        }, bgColor: Theme.of(context).primaryColor, fontColor: Theme.of(context).cardColor),
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
    bool isFirst = index == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: rs.getSize(10)),
              child: MyWidget().getTextWidget(rs,
                  text: (index + 1).toString(), color: Theme.of(context).primaryColor, isBold: true),
            )),
            Obx(() => FavoriteIcon().getFlashcardIcon(key: isFirst ? keyFlashcard : null, context, rs,
                controller: controller,
                itemId: reading.id,
                front: reading.content[KO],
                back: reading.content[fo],
                audio: 'ReadingAudios_${readingTitle.id}_${reading.id}')),
            GestureDetector(
              key: isFirst ? keyAudio : null,
              onTap: () async {
                PlayAudio().stop();
                if (reading.isPlay) {
                  setPlayStopIcon(index, isForward: false);
                } else {
                  String fileName = reading.id;
                  if (audioPaths.containsKey(fileName)) {
                    String path = audioPaths[fileName]!;
                    PlayAudio().player.setFilePath(path);
                    PlayAudio().player.setVolume(1);
                    PlayAudio().player.playerStateStream.listen((event) {
                      if (event.processingState == ProcessingState.completed) {
                        setPlayStopIcon(index, isForward: false);
                        PlayAudio().stream.cancel();
                      }
                    });
                    PlayAudio().player.play();
                  }
                  for (int i = 0; i < readings.length; i++) {
                    setPlayStopIcon(i, isForward: false);
                  }
                  setPlayStopIcon(index, isForward: true);
                }
              },
              child: playStopIcons[reading.id]!.icon,
            )
          ],
        ),
        Container(
          key: isFirst ? keySentence : null,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: MyWidget().getTextWidget(rs,
              text: contentKo,
              size: 18,
              height: 1.8,
              isKorean: true,
              color: Theme.of(context).secondaryHeaderColor),
        ),
      ],
    );
  }

  Widget partContentFo(int index) {
    final contentFo = readings[index].content[fo];
    bool isFirst = index == 0;
    return ExpansionTile(
      onExpansionChanged: (value) {
        controller.setIsExpanded(index, value);
      },
      leading: Icon(key: isFirst ? keyTranslate : null, CupertinoIcons.globe, size: rs.getSize(20)),
      iconColor: Theme.of(context).primaryColor,
      collapsedIconColor: Theme.of(context).disabledColor,
      title: const Text(''),
      childrenPadding: EdgeInsets.symmetric(horizontal: rs.getSize(10)),
      children: [
        MyWidget().getTextWidget(rs, text: contentFo, color: Theme.of(context).disabledColor),
        SizedBox(height: rs.getSize(20)),
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
                SizedBox(
                  height: 10,
                  child: VerticalDivider(
                    color: Theme.of(context).primaryColor,
                    thickness: 1,
                    width: 18,
                  ),
                ),
                MyWidget().getTextWidget(rs,
                    text: wordKoList[index],
                    isKorean: true,
                    size: 18,
                    color: Theme.of(context).secondaryHeaderColor),
                const Text(' : '),
                MyWidget()
                    .getTextWidget(rs, text: wordFoList[index], color: Theme.of(context).secondaryHeaderColor)
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    rs = ResponsiveSize(context);

    myTutorial = MyTutorial();
    bool isTutorialEnabled = myTutorial!.isTutorialEnabled(myTutorial!.TUTORIAL_READING_FRAME) && isLoading == false;
    if(isTutorialEnabled) {
      keySaveReading = GlobalKey();
      keySentence = GlobalKey();
      keyFlashcard = GlobalKey();
      keyAudio = GlobalKey();
      keyTranslate = GlobalKey();
      List<TargetFocus> targets = [
        myTutorial!.tutorialItem(id: "T1", keyTarget: keySaveReading, content: tr('tutorial_reading_frame_1')),
        myTutorial!.tutorialItem(id: "T2", keyTarget: keySentence, content: tr('tutorial_reading_frame_2')),
        myTutorial!.tutorialItem(id: "T3", keyTarget: keyFlashcard, content: tr('tutorial_reading_frame_3')),
        myTutorial!.tutorialItem(id: "T4", keyTarget: keyAudio, content: tr('tutorial_reading_frame_4')),
        myTutorial!.tutorialItem(id: "T5", keyTarget: keyTranslate, content: tr('tutorial_reading_frame_5')),
      ];
      myTutorial!.addTargetsAndRunTutorial(context, targets);

    } else {
      myTutorial = null;
    }

    return Scaffold(
      body: isLoading
          ? MyWidget().getLoading(context, rs, progressValue)
          : Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: readings.isEmpty
                ? Center(
                    child: MyWidget().getTextWidget(
                      rs,
                      text: tr('noReading'),
                      color: Theme.of(context).primaryColor,
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
                                builder: (controller) {
                                  FirebaseCrashlytics.instance.log('bannerAd : ${controller.bannerAd}');
                                  if (controller.bannerAd != null && controller.isBannerAdLoaded) {
                                    return Container(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      width: controller.bannerAd!.size.width.toDouble(),
                                      height: controller.bannerAd!.size.height.toDouble(),
                                      child: AdWidget(ad: controller.bannerAd!),
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
          ),
    );
  }
}
