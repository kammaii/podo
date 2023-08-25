import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio/just_audio.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:podo/common/ads_controller.dart';
import 'package:podo/common/cloud_storage.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/lesson/lesson_card.dart';
import 'package:podo/screens/lesson/lesson_controller.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class LessonFrame extends StatefulWidget {
  LessonFrame({Key? key}) : super(key: key);

  @override
  State<LessonFrame> createState() => _LessonFrameState();
}

class _LessonFrameState extends State<LessonFrame> with SingleTickerProviderStateMixin {
  final lesson = Get.arguments;
  int thisIndex = 0;
  final controller = Get.find<LessonController>();
  final KO = 'ko';
  final PRONUN = 'pronun';
  final EX1 = 'ex1';
  final EX2 = 'ex2';
  final EX3 = 'ex3';
  final EX4 = 'ex4';
  final AUDIO = 'audio';
  final VIDEO = 'video';
  final FILE_NAME = 'fileName';
  final SPEAKING = 'speaking';
  String fo = User().language;
  bool isLoading = true;
  List<LessonCard> cards = [];
  List<String> examples = [];
  late String answer;
  int selectedAnswer = -1;
  Color quizBorderColor = Colors.white;
  SwiperController swiperController = SwiperController();
  Map<String, String> audioPaths = {};
  late AnimationController animationController;
  late Animation<Offset> animationOffset;
  late Widget bottomWidget;
  final Map<String, Uint8List> _imageCache = {};
  late double progressValue;
  AudioPlayer audioPlayerForEffect = AudioPlayer();

  Widget _getCachedImage(String base64Str) {
    if (_imageCache.containsKey(base64Str)) {
      return Image.memory(_imageCache[base64Str]!, fit: BoxFit.cover);
    } else {
      var bytes = base64.decode(base64Str);
      _imageCache[base64Str] = bytes;
      return Image.memory(bytes, fit: BoxFit.cover);
    }
  }

  Widget getHtmlWidget(String html) {
    return HtmlWidget(
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
      textStyle: const TextStyle(
        fontFamily: 'EnglishFont',
        fontSize: 17,
        height: 1.3,
      ),
    );
  }

  void openDetail(String title, String content) {
    Get.dialog(AlertDialog(
      title: Row(
        children: [
          GestureDetector(
              onTap: () {
                Get.back();
              },
              child: const Icon(Icons.arrow_back_ios_rounded, color: MyColors.purple)),
          const SizedBox(width: 10),
          Expanded(child: MyWidget().getTextWidget(text: title, color: MyColors.purple, isBold: true, size: 18)),
        ],
      ),
      content: SingleChildScrollView(child: getHtmlWidget(content)),
    ));
  }

  Widget getCards(int index) {
    LessonCard card = cards[index];
    String type = card.type;
    Widget widget;

    switch (type) {
      case MyStrings.subject:
        widget = Column(
          children: [
            Row(
              children: [
                const Icon(Icons.flag_outlined, size: 18),
                const SizedBox(height: 10),
                Text(tr('newExpression')),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MyWidget().getTextWidget(
                    text: card.content[KO],
                    size: 30,
                    color: Colors.black,
                    isKorean: true,
                  ),
                  MyWidget().getTextWidget(
                    text: card.content[fo],
                    size: 20,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ],
        );
        break;

      case MyStrings.explain:
        widget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.feed_outlined, size: 18),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: getHtmlWidget(card.content[fo]),
              ),
            ),
          ],
        );
        break;

      case MyStrings.repeat:
        widget = Column(
          children: [
            Row(
              children: [
                const Icon(Icons.hearing, size: 18),
                const SizedBox(width: 8),
                MyWidget().getTextWidget(text: tr('listenAndRepeat')),
              ],
            ),
            const SizedBox(height: 50),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    if (controller.hasFlashcard[card.id]) {
                                      FlashCard().removeFlashcard(itemId: card.id);
                                      controller.hasFlashcard[card.id] = false;
                                    } else {
                                      FlashCard().addFlashcard(
                                          itemId: card.id,
                                          front: card.content[KO],
                                          back: card.content[fo],
                                          audio: 'LessonAudios_${lesson.id}_${card.content[AUDIO]}',
                                          fn: () {
                                            controller.hasFlashcard[card.id] = true;
                                          });
                                    }
                                  },
                                  icon: Icon(
                                    controller.hasFlashcard[card.id]
                                        ? CupertinoIcons.heart_fill
                                        : CupertinoIcons.heart,
                                    color: MyColors.purple,
                                  ))
                            ],
                          )),
                      const SizedBox(height: 10),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: MyWidget()
                            .getTextWidget(text: card.content[KO], size: 30, color: Colors.black, isKorean: true),
                      ),
                      const SizedBox(height: 20),
                      card.content[PRONUN] != null
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: MyWidget().getTextWidget(
                                  text: '[${card.content[PRONUN]}]',
                                  size: 18,
                                  color: Colors.black,
                                  isKorean: true),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 20),
                    ],
                  ),
                  MyWidget().getTextWidget(
                    text: card.content[fo],
                    color: Colors.black,
                  ),
                ],
              ),
            )
          ],
        );
        break;

      case MyStrings.mention:
        widget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 18),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Offstage(
                          offstage: card.content[KO] == null,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: MyWidget().getTextWidget(text: card.content[KO], isKorean: true, size: 20),
                          )),
                      MyWidget().getTextWidget(text: card.content[fo], size: 20),
                      card.content[VIDEO] != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: YoutubePlayer(
                                controller: YoutubePlayerController(
                                  initialVideoId: YoutubePlayer.convertUrlToId(card.content[VIDEO])!,
                                  flags: const YoutubePlayerFlags(),
                                ),
                                actionsPadding: const EdgeInsets.all(10),
                                bottomActions: [
                                  CurrentPosition(),
                                  const SizedBox(width: 10),
                                  ProgressBar(isExpanded: true),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                      card.detailTitle != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(User().status == 1 ? CupertinoIcons.lock_circle : Icons.ads_click,
                                      color: MyColors.purple),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextButton(
                                        onPressed: () {
                                          if (User().status != 1) {
                                            openDetail(card.detailTitle![fo], card.detailContent![fo]);
                                          } else {
                                            Get.toNamed('/premiumMain');
                                          }
                                        },
                                        child: MyWidget().getTextWidget(
                                          text: card.detailTitle![fo],
                                          color: MyColors.purple,
                                          size: 17,
                                          hasUnderline: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
        break;

      case MyStrings.tip:
        widget = Column(
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 18),
                const SizedBox(width: 8),
                MyWidget().getTextWidget(text: tr('teachersTip')),
              ],
            ),
            Expanded(
              child: Center(
                child: MyWidget().getTextWidget(text: card.content[fo], size: 20),
              ),
            )
          ],
        );
        break;

      case MyStrings.quiz:
        if (index == thisIndex && examples.isEmpty) {
          examples = [card.content[EX1], card.content[EX2], card.content[EX3], card.content[EX4]];
          answer = card.content[EX1];
          examples.shuffle(Random());
        }
        String question;
        if (card.content[KO] == null || card.content[KO].toString().isEmpty) {
          question = card.content[fo];
        } else {
          question = card.content[KO];
        }
        widget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.question_mark_rounded, size: 18),
                const SizedBox(width: 8),
                MyWidget().getTextWidget(text: tr('takeQuiz')),
              ],
            ),
            const SizedBox(height: 50),
            MyWidget().getTextWidget(text: question, size: 15, color: Colors.black),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: examples.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        selectedAnswer = index;
                        if (examples[index] == answer) {
                          quizBorderColor = MyColors.purple;
                          effectAudioPlay(isCorrect: true);
                          Future.delayed(const Duration(seconds: 1), () {
                            swiperController.move(thisIndex + 1);
                            quizBorderColor = Colors.white;
                          });
                        } else {
                          quizBorderColor = MyColors.red;
                          effectAudioPlay(isCorrect: false);
                          Future.delayed(const Duration(seconds: 1), () {
                            setState(() {
                              quizBorderColor = Colors.white;
                            });
                          });
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: selectedAnswer == index ? quizBorderColor : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 0.5,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              )
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                          child:
                              MyWidget().getTextWidget(text: '${index + 1}. ${examples[index]}', isKorean: true),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
        break;

      default:
        widget = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Card(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: widget,
      )),
    );
  }

  toggleBottomAudioWidget(bool isForward) {
    if (isForward) {
      controller.update();
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    bottomWidget = const SizedBox.shrink();
    progressValue = 0.0;

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animationOffset = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(animationController);

    final Query query =
        FirebaseFirestore.instance.collection('Lessons/${lesson.id}/LessonCards').orderBy('orderId');

    Future.wait([
      Database().getDocs(query: query),
      CloudStorage().downloadAudios(folderName: 'LessonAudios', folderId: lesson.id),
    ]).then((snapshots) async {
      int totalCards = snapshots[0].length;
      double incrementPerCard = 0.2 / totalCards;

      Map<String, bool> flashcardMap = {};
      for (dynamic snapshot in snapshots[0]) {
        LessonCard card = LessonCard.fromJson(snapshot.data() as Map<String, dynamic>);
        if (card.type == MyStrings.repeat) {
          flashcardMap[card.id] = LocalStorage().hasFlashcard(itemId: card.id);
        }
        cards.add(card);
        progressValue += incrementPerCard;
        setState(() {});
      }
      controller.hasFlashcard.value = flashcardMap.obs;
      Map<String, String> audios = {};
      for (dynamic snapshot in snapshots[1]) {
        audios.addAll(snapshot);
      }
      await cacheFiles(audios);
      setState(() {
        isLoading = false;
      });
    });
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

  void effectAudioPlay({required bool isCorrect}) async {
    String effect = 'correct';
    if(!isCorrect) {
      effect = 'wrong';
    }
    try {
      await audioPlayerForEffect.setAsset('assets/audio/$effect.mp3');
      await audioPlayerForEffect.setVolume(0.1);
      audioPlayerForEffect.play();
    } catch (e) {
      print('Error: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyWidget().getAppbar(title: lesson.title[KO], isKorean: true),
      body: isLoading
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyWidget().getTextWidget(text: 'Loading...', color: MyColors.purple),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progressValue,
                    valueColor: const AlwaysStoppedAnimation<Color>(MyColors.purple),
                    backgroundColor: MyColors.navyLight,
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  LinearPercentIndicator(
                    animateFromLastPercent: true,
                    animation: true,
                    lineHeight: 3.0,
                    percent: thisIndex / cards.length,
                    backgroundColor: MyColors.navyLight,
                    progressColor: MyColors.purple,
                  ),
                  Expanded(
                    child: Swiper(
                      controller: swiperController,
                      itemBuilder: (context, index) {
                        if (index < cards.length) {
                          return getCards(index);
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                      loop: false,
                      itemCount: cards.length + 1,
                      viewportFraction: 0.8,
                      scale: 0.8,
                      onIndexChanged: (index) {
                        if (index >= cards.length) {
                          Get.toNamed(MyStrings.routeLessonComplete, arguments: lesson);
                          return;
                        } else {
                          setState(() {
                            thisIndex = index;
                            examples.clear();
                            autoPlayAudio();
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 170,
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          child: SlideTransition(
                            position: animationOffset,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 30),
                                child: GetBuilder<LessonController>(
                                  builder: (_) {
                                    LessonCard card = cards[thisIndex];
                                    if (card.content.containsKey(AUDIO)) {
                                      toggleBottomAudioWidget(true);
                                      return Column(
                                        children: [
                                          Visibility(
                                            visible: card.type == MyStrings.repeat,
                                            child: MyWidget().getTextWidget(
                                              text: tr('practice3Times'),
                                              size: 15,
                                              color: MyColors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              getSpeedBtn(isNormal: true),
                                              const SizedBox(width: 20),
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  CircularPercentIndicator(
                                                    radius: 30,
                                                    lineWidth: 4,
                                                    percent: controller.audioProgress,
                                                    animateFromLastPercent: true,
                                                    progressColor: MyColors.purple,
                                                  ),
                                                  IconButton(
                                                    iconSize: 60,
                                                    onPressed: () {
                                                      controller.playAudio();
                                                    },
                                                    icon: const Icon(
                                                      Icons.play_arrow_rounded,
                                                      color: MyColors.purple,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 20),
                                              getSpeedBtn(isNormal: false),
                                            ],
                                          )
                                        ],
                                      );
                                    } else {
                                      toggleBottomAudioWidget(false);
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  User().status == 1
                      ? GetBuilder<AdsController>(
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
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
    );
  }

  void autoPlayAudio() {
    PlayAudio().player.stop();
    if (cards[thisIndex].content.containsKey(AUDIO)) {
      String fileName = cards[thisIndex].content[AUDIO];
      if (audioPaths.containsKey(fileName)) {
        String path = audioPaths[fileName]!;
        controller.setAudioPathAndPlay(path: path);
      }
    }
  }

  Widget getSpeedBtn({required isNormal}) {
    Color containerColor;
    Color borderColor;
    if (isNormal && controller.audioSpeedToggle[0] || !isNormal && controller.audioSpeedToggle[1]) {
      containerColor = MyColors.navyLight;
      borderColor = Colors.white;
    } else {
      containerColor = Colors.white;
      borderColor = MyColors.purple;
    }

    return GestureDetector(
      onTap: () {
        isNormal
            ? controller.changeAudioSpeedToggle(isNormal: true)
            : controller.changeAudioSpeedToggle(isNormal: false);
      },
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          color: containerColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Center(
          child: MyWidget().getTextWidget(
              text: isNormal ? tr('normal') : tr('speedDown'), color: MyColors.purple, isBold: true),
        ),
      ),
    );
  }
}
