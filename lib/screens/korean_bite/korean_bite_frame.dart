import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podo/common/ads_controller.dart';
import 'package:podo/common/cloud_storage.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/favorite_icon.dart';
import 'package:podo/common/history.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_Stop_icon.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/korean_bite/korean_bite_controller.dart';
import 'package:podo/screens/korean_bite/korean_bite_example.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:http/http.dart' as http;
import 'package:podo/values/my_colors.dart';

class KoreanBiteFrame extends StatefulWidget {
  const KoreanBiteFrame({super.key});

  @override
  State<KoreanBiteFrame> createState() => _KoreanBiteFrameState();
}

class _KoreanBiteFrameState extends State<KoreanBiteFrame> with TickerProviderStateMixin {
  late bool isLoading;
  late double progressValue;
  Map<String, String> audioPaths = {};
  late ResponsiveSize rs;
  Map<String, PlayStopIcon> playStopIcons = {};
  late List<KoreanBiteExample> examples;
  late AnimationController animationController;
  late Animation<double> animation;
  ScrollController scrollController = ScrollController();
  final koreanBite = Get.arguments;
  final KO = 'ko';
  String fo = User().language;
  final controller = Get.find<KoreanBiteController>();
  double sliverAppBarHeight = 200.0;
  double sliverAppBarStretchOffset = 100.0;
  final Map<String, Uint8List> _imageCache = {};

  @override
  void initState() {
    super.initState();
    isLoading = true;
    examples = [];
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
        }));

    final firestore = FirebaseFirestore.instance;
    final biteDoc = 'KoreanBites/${koreanBite.id}';
    Future.wait([
      Database().getDocs(query: firestore.collection('$biteDoc/Examples').orderBy('orderId')),
      CloudStorage().downloadAudios(folderName: 'KoreanBitesAudios', folderId: koreanBite.id),
    ]).then((snapshots) async {
      await FirebaseAnalytics.instance.logSelectContent(contentType: 'koreanBite', itemId: koreanBite.title[KO]);
      int totalExamples = snapshots[0].length;
      double incrementPerExample = 0.2 / totalExamples;
      controller.hasFlashcard.value = {};
      for (dynamic snapshot in snapshots[0]) {
        KoreanBiteExample example = KoreanBiteExample.fromJson(snapshot.data() as Map<String, dynamic>);
        examples.add(example);
        progressValue += incrementPerExample;
        controller.hasFlashcard[example.id] = LocalStorage().hasFlashcard(itemId: example.id);
        if (mounted) {
          playStopIcons[example.id] = PlayStopIcon(rs, this);
          setState(() {});
        }
      }

      Map<String, String> audios = {};
      for (dynamic snapshot in snapshots[1]) {
        audios.addAll(snapshot);
      }
      await cacheFiles(audios);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    animationController.dispose();
    AdsController().bannerAd?.dispose();
    PlayAudio().reset();
    super.dispose();
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

  void setPlayStopIcon(KoreanBiteExample example, {required bool isForward}) {
    if (isForward) {
      playStopIcons[example.id]!.clickIcon(isForward: true);
      example.isPlay = true;
    } else {
      playStopIcons[example.id]!.clickIcon(isForward: false);
      example.isPlay = false;
    }
  }

  Widget _getCachedImage(String base64Str) {
    if (_imageCache.containsKey(base64Str)) {
      return Image.memory(_imageCache[base64Str]!, fit: BoxFit.cover);
    } else {
      var bytes = base64.decode(base64Str);
      _imageCache[base64Str] = bytes;
      return Image.memory(bytes, fit: BoxFit.cover);
    }
  }

  sliverAppBar() {
    return SliverAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          size: rs.getSize(20),
          color: MyColors.purple,
        ),
        color: MyColors.purple,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      expandedHeight: rs.getSize(sliverAppBarHeight),
      collapsedHeight: rs.getSize(60),
      pinned: true,
      stretch: true,
      title: MyWidget().getTextWidget(
        rs,
        text: '${koreanBite.title[KO]}',
        size: 18,
        color: MyColors.purple,
        isBold: true,
      ),
      flexibleSpace: Stack(
        children: [
          Container(
            color: Theme.of(context).primaryColorLight,
          ),
          Positioned(
            top: 0,
            right: -30,
            child: FadeTransition(
              opacity: animation,
              child: Icon(Icons.cookie_outlined, size: 250, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  sliverList() {
    String html = koreanBite.explain[fo] ?? koreanBite.explain['en'];
    List<Widget> l = [];
    for (KoreanBiteExample example in examples) {
      l.add(getExampleWidget(example));
    }

    return SliverPadding(
        padding: EdgeInsets.all(rs.getSize(20)),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            MyWidget().getTextWidget(rs,
                text: tr('explain'), isBold: true, hasUnderline: true, size: 20, color: MyColors.purple),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: HtmlWidget(
                  html,
                  customWidgetBuilder: (element) {
                    if (element.localName == 'img') {
                      var src = element.attributes['src'];
                      if (src != null && src.startsWith("data:image")) {
                        var base64Str = src.split(",")[1];
                        return _getCachedImage(base64Str);
                      }
                    }
                    return null;
                  },
                  textStyle: TextStyle(
                      fontFamily: 'EnglishFont',
                      fontSize: rs.getSize(18),
                      height: 1.5,
                      color: Theme.of(context).secondaryHeaderColor),
                ),
              ),
            ),
            const SizedBox(height: 30),
            MyWidget().getTextWidget(rs,
                text: tr('examples'), isBold: true, hasUnderline: true, size: 20, color: MyColors.purple),
            const SizedBox(height: 10),
            ...List.generate(examples.length, (index) => getExampleWidget(examples[index])),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(bottom: rs.getSize(100)),
              child: MyWidget().getRoundBtnWidget(rs, text: tr('complete'), f: () {
                History().addHistory(itemIndex: 3, itemId: koreanBite.id, content: koreanBite.title[KO]);
                controller.isCompleted[koreanBite.id] = true;
                Get.back();
              }, bgColor: Theme.of(context).primaryColor, fontColor: Theme.of(context).cardColor),
            ),
          ]),
        ));
  }

  Widget getExampleWidget(KoreanBiteExample example) {
    String e = example.example;
    List<TextSpan> spans = [];
    RegExp regex = RegExp(r'\$(.*?)\$'); // $$ 안의 문자 찾기
    Iterable<RegExpMatch> matches = regex.allMatches(e);
    int lastIndex = 0;
    for (final match in matches) {
      // $ 앞의 일반 문자열 추가
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: e.substring(lastIndex, match.start),
        ));
      }

      // $$ 안의 문자열 (빨간색)
      spans.add(TextSpan(
        text: match.group(1), // 캡처된 문자열
        style: TextStyle(color: MyColors.red),
      ));

      lastIndex = match.end;
    }

    // 마지막 남은 문자열 추가
    if (lastIndex < e.length) {
      spans.add(TextSpan(
        text: e.substring(lastIndex),
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Card(
            child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => FavoriteIcon().getFlashcardIcon(context, rs,
                            controller: controller,
                            itemId: example.id,
                            front: example.example.replaceAll("\$", ""),
                            back: example.exampleTrans[fo],
                            audio: 'KoreanBitesAudios_${koreanBite.id}_${example.id}')),
                        GestureDetector(
                          onTap: () async {
                            PlayAudio().stop();
                            if (example.isPlay) {
                              setPlayStopIcon(example, isForward: false);
                            } else {
                              String fileName = example.id;
                              if (audioPaths.containsKey(fileName)) {
                                String path = audioPaths[fileName]!;
                                PlayAudio().player.setFilePath(path);
                                PlayAudio().player.setVolume(1);
                                PlayAudio().player.playerStateStream.listen((event) {
                                  if (event.processingState == ProcessingState.completed) {
                                    setPlayStopIcon(example, isForward: false);
                                    PlayAudio().stream.cancel();
                                  }
                                });
                                PlayAudio().player.play();
                              }
                              for (int i = 0; i < examples.length; i++) {
                                setPlayStopIcon(examples[i], isForward: false);
                              }
                              setPlayStopIcon(example, isForward: true);
                            }
                          },
                          child: playStopIcons[example.id]!.icon,
                        ),
                      ],
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text.rich(TextSpan(children: spans),
                          style: TextStyle(fontSize: 20, fontFamily: 'KoreanFont', height: 1.5)),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: MyWidget()
                          .getTextWidget(rs, text: example.exampleTrans[fo], color: MyColors.grey),
                    )
                  ],
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 10),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    rs = ResponsiveSize(context);

    return Scaffold(
      body: isLoading
          ? MyWidget().getLoading(context, rs, progressValue)
          : Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      controller: scrollController,
                      slivers: [
                        sliverAppBar(),
                        sliverList(),
                      ],
                    ),
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
