import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio/just_audio.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:podo/common/ads_controller.dart';
import 'package:podo/common/cloud_storage.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/flashcard_icon.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/lesson/lesson_card.dart';
import 'package:podo/screens/lesson/lesson_controller.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
  final CLIP_START = 'clipStart';
  final CLIP_END = 'clipEnd';
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
  late Map<String, yt.YoutubePlayerController> youtubeControllers;
  List<String>? firstAudioCards;
  late ResponsiveSize rs;

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
      textStyle: TextStyle(
          fontFamily: 'EnglishFont',
          fontSize: rs.getSize(17),
          height: 1.3,
          color: Theme.of(context).secondaryHeaderColor),
    );
  }

  void openDetail(String title, String content) {
    Get.dialog(AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      title: Row(
        children: [
          GestureDetector(
              onTap: () {
                Get.back();
              },
              child:
                  Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).primaryColor, size: rs.getSize(20))),
          SizedBox(width: rs.getSize(10)),
          Expanded(
              child: MyWidget()
                  .getTextWidget(rs, text: title, color: Theme.of(context).primaryColor, isBold: true, size: 18)),
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
                Icon(Icons.flag_outlined, size: rs.getSize(18), color: Theme.of(context).secondaryHeaderColor),
                SizedBox(height: rs.getSize(10)),
                MyWidget()
                    .getTextWidget(rs, text: tr('newExpression'), color: Theme.of(context).secondaryHeaderColor),
              ],
            ),
            Expanded(
              child: Center(
                child: MyWidget().getTextWidget(
                  rs,
                  text: card.content[KO],
                  size: 30,
                  color: Theme.of(context).secondaryHeaderColor,
                  isKorean: true,
                ),
              ),
            ),
          ],
        );
        break;

      case MyStrings.explain:
        String html = card.content[fo] ?? card.content['en'];
        widget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.feed_outlined, size: rs.getSize(18), color: Theme.of(context).secondaryHeaderColor),
            SizedBox(height: rs.getSize(10)),
            Expanded(
              child: SingleChildScrollView(
                child: getHtmlWidget(html),
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
                Icon(Icons.hearing, size: rs.getSize(18), color: Theme.of(context).secondaryHeaderColor),
                SizedBox(width: rs.getSize(8)),
                MyWidget()
                    .getTextWidget(rs, text: tr('listenAndRepeat'), color: Theme.of(context).secondaryHeaderColor),
              ],
            ),
            SizedBox(height: rs.getSize(50)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Obx(() => FlashcardIcon().getIconButton(context, rs,
                              controller: controller,
                              itemId: card.id,
                              front: card.content[KO],
                              back: card.content[fo],
                              audio: 'LessonAudios_${lesson.id}_${card.content[AUDIO]}')),
                        ],
                      ),
                      SizedBox(height: rs.getSize(10)),
                      AutoSizeText(
                        card.content[KO],
                        style: TextStyle(fontSize: rs.getSize(25), color: Theme.of(context).secondaryHeaderColor),
                        maxLines: 2,
                      ),
                      SizedBox(height: rs.getSize(20)),
                      card.content[PRONUN] != null && card.content[PRONUN].toString().isNotEmpty
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: MyWidget().getTextWidget(rs,
                                  text: '[${card.content[PRONUN]}]',
                                  size: 18,
                                  color: Theme.of(context).secondaryHeaderColor,
                                  isKorean: true),
                            )
                          : const SizedBox.shrink(),
                      SizedBox(height: rs.getSize(20)),
                    ],
                  ),
                  MyWidget().getTextWidget(
                    rs,
                    text: card.content[fo],
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ],
              ),
            )
          ],
        );
        break;

      case MyStrings.mention:
        if (card.content[VIDEO] != null && youtubeControllers.containsKey(card.id)) {
          if (index == thisIndex) {
            youtubeControllers[card.id]!.play();
          } else {
            youtubeControllers[card.id]!.pause();
          }
        }
        widget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.chat_bubble_outline, size: rs.getSize(18), color: Theme.of(context).secondaryHeaderColor),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Offstage(
                          offstage: card.content[KO] == null,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: rs.getSize(20)),
                            child: MyWidget().getTextWidget(rs,
                                text: card.content[KO],
                                isKorean: true,
                                size: 20,
                                color: Theme.of(context).secondaryHeaderColor),
                          )),
                      MyWidget().getTextWidget(rs,
                          text: card.content[fo], size: 20, color: Theme.of(context).secondaryHeaderColor),
                      card.content[VIDEO] != null && index == thisIndex
                          ? Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: rs.getSize(20)),
                                  child: yt.YoutubePlayer(
                                    controller: youtubeControllers[card.id]!,
                                    actionsPadding: EdgeInsets.all(rs.getSize(10)),
                                    bottomActions: [
                                      yt.CurrentPosition(),
                                      SizedBox(width: rs.getSize(10)),
                                      yt.ProgressBar(isExpanded: true),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                        onPressed: () async {
                                          String replace = Platform.isIOS ? 'youtube://' : 'vnd.youtube://';
                                          final url = Uri.parse(
                                              card.content[VIDEO]!.toString().replaceFirst('https://', replace));
                                          try {
                                            print('try');
                                            await launchUrl(url);
                                          } catch (e) {
                                            print('error: $e');
                                            MyWidget().showSimpleDialog(tr('error'), e.toString());
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Icon(FontAwesomeIcons.youtube, color: Theme.of(context).focusColor),
                                            const SizedBox(width: 8),
                                            Text(tr('watchOnYoutube'),
                                                style: TextStyle(color: Theme.of(context).focusColor)),
                                          ],
                                        )),
                                  ],
                                )
                              ],
                            )
                          : const SizedBox.shrink(),
                      card.detailTitle != null
                          ? Padding(
                              padding: EdgeInsets.only(top: rs.getSize(20)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(User().status == 1 ? CupertinoIcons.lock_circle : Icons.ads_click,
                                      color: Theme.of(context).primaryColor, size: rs.getSize(20)),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextButton(
                                        onPressed: () {
                                          if (User().status != 1) {
                                            openDetail(card.detailTitle![fo], card.detailContent![fo]);
                                          } else {
                                            MyWidget().showDialog(context, rs, content: tr('wantUnlockDetail'),
                                                yesFn: () {
                                              Get.toNamed(MyStrings.routePremiumMain);
                                            },
                                                hasPremiumTag: true,
                                                hasNoBtn: false,
                                                yesText: tr('explorePremium'));
                                          }
                                        },
                                        child: MyWidget().getTextWidget(
                                          rs,
                                          text: card.detailTitle![fo],
                                          color: Theme.of(context).primaryColor,
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
                Icon(Icons.lightbulb_outline, size: rs.getSize(18), color: Theme.of(context).secondaryHeaderColor),
                SizedBox(width: rs.getSize(8)),
                MyWidget()
                    .getTextWidget(rs, text: tr('teachersTip'), color: Theme.of(context).secondaryHeaderColor),
              ],
            ),
            Expanded(
              child: Center(
                child: MyWidget().getTextWidget(rs,
                    text: card.content[fo], size: 20, color: Theme.of(context).secondaryHeaderColor),
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
                Icon(Icons.question_mark_rounded,
                    size: rs.getSize(18), color: Theme.of(context).secondaryHeaderColor),
                SizedBox(width: rs.getSize(8)),
                MyWidget().getTextWidget(rs, text: tr('takeQuiz'), color: Theme.of(context).secondaryHeaderColor),
              ],
            ),
            SizedBox(height: rs.getSize(50)),
            MyWidget().getTextWidget(rs, text: question, color: Theme.of(context).secondaryHeaderColor),
            SizedBox(height: rs.getSize(20)),
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
                            quizBorderColor = Theme.of(context).cardColor;
                          });
                        } else {
                          quizBorderColor = MyColors.red;
                          effectAudioPlay(isCorrect: false);
                          Future.delayed(const Duration(seconds: 1), () {
                            setState(() {
                              quizBorderColor = Theme.of(context).cardColor;
                            });
                          });
                        }
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(bottom: rs.getSize(20)),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            border: Border.all(
                                color: selectedAnswer == index ? quizBorderColor : Theme.of(context).cardColor),
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
                          padding: EdgeInsets.symmetric(vertical: rs.getSize(15), horizontal: rs.getSize(10)),
                          child: MyWidget().getTextWidget(rs,
                              text: '${index + 1}. ${examples[index]}',
                              isKorean: true,
                              color: Theme.of(context).secondaryHeaderColor),
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
      padding: EdgeInsets.only(top: rs.getSize(50)),
      child: Card(
          child: Padding(
        padding: EdgeInsets.all(rs.getSize(20)),
        child: widget,
      )),
    );
  }

  toggleBottomAudioWidget(bool isForward) {
    if (isForward) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    for (final controller in youtubeControllers.values) {
      controller.dispose();
    }
    if (User().status == 1) {
      AdsController().bannerAd?.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    bottomWidget = const SizedBox.shrink();
    progressValue = 0.0;
    youtubeControllers = {};
    firstAudioCards = [];

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
      double incrementPerCard = 0.4 / totalCards;

      Map<String, bool> flashcardMap = {};
      bool videoEnded = false;
      int clipStart = 0;
      int? clipEnd;

      if (User().status == 1) {
        _loadAd();
      }

      for (dynamic snapshot in snapshots[0]) {
        LessonCard card = LessonCard.fromJson(snapshot.data() as Map<String, dynamic>);
        if (card.type == MyStrings.repeat) {
          flashcardMap[card.id] = LocalStorage().hasFlashcard(itemId: card.id);
        }
        if (card.content[VIDEO] != null) {
          if (card.content[CLIP_START] != null &&
              card.content[CLIP_END] != null &&
              card.content[CLIP_START].toString().isNotEmpty &&
              card.content[CLIP_END].toString().isNotEmpty) {
            clipStart = int.parse(card.content[CLIP_START]);
            clipEnd = int.parse(card.content[CLIP_END]);
          }
          yt.YoutubePlayerController youtubeController = yt.YoutubePlayerController(
              initialVideoId: yt.YoutubePlayer.convertUrlToId(card.content[VIDEO])!,
              flags: yt.YoutubePlayerFlags(
                startAt: clipStart,
              ));
          youtubeController.addListener(() {
            if (!videoEnded &&
                youtubeController.value.isReady &&
                youtubeController.value.playerState == yt.PlayerState.ended) {
              print('ENDED');
              videoEnded = true;
              youtubeController.seekTo(Duration(seconds: clipStart));
              youtubeController.pause();
            } else if (youtubeController.value.playerState == yt.PlayerState.playing) {
              print('PLAYING');
              videoEnded = false;
              if (clipEnd != null && youtubeController.value.position >= Duration(seconds: clipEnd)) {
                print('CLIP END');
                youtubeController.seekTo(Duration(seconds: clipStart));
                youtubeController.pause();
              }
            }
          });
          youtubeControllers[card.id] = youtubeController;
        }
        String? audioId = card.content[AUDIO];
        if (audioId != null && firstAudioCards!.length < 3 && !firstAudioCards!.contains(audioId)) {
          firstAudioCards!.add(card.content[AUDIO]);
        }
        cards.add(card);
        progressValue += incrementPerCard;
        if (mounted) {
          setState(() {});
        }
      }
      controller.hasFlashcard.value = flashcardMap.obs;
      Map<String, String> audios = {};
      for (dynamic snapshot in snapshots[1]) {
        audios.addAll(snapshot);
      }
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        if (firstAudioCards!.isNotEmpty) {
          await cacheFiles(audios);
        } else {
          setState(() {
            progressValue = 1;
            isLoading = false;
          });
        }
      });
    });
  }

  Future<void> cacheFiles(Map<String, String> snapshots) async {
    final directory = await getTemporaryDirectory();
    audioPaths = {};
    double incrementPerFile = 0.6 / 2;

    for (var card in cards) {
      String? audioId = card.content[AUDIO];
      if (audioId != null && audioPaths[audioId] == null) {
        final url = snapshots[audioId];
        final response = await http.get(Uri.parse(url!));
        final File file = File('${directory.path}/$audioId.m4a');
        await file.writeAsBytes(response.bodyBytes);
        audioPaths[audioId] = file.path;
        progressValue += incrementPerFile;

        if (firstAudioCards != null) {
          if (firstAudioCards!.contains(audioId)) {
            firstAudioCards!.remove(audioId);
          }

          if (firstAudioCards!.isEmpty && mounted) {
            setState(() {
              progressValue = 1;
              firstAudioCards = null;
              isLoading = false;
            });
          }

          if (mounted && isLoading) {
            setState(() {});
          }
        }
      }
    }
  }

  void effectAudioPlay({required bool isCorrect}) async {
    String effect = 'correct';
    if (!isCorrect) {
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
    rs = ResponsiveSize(context);
    return Scaffold(
      appBar: MyWidget().getAppbar(context, rs, title: lesson.title[KO], isKorean: true),
      body: isLoading
          ? MyWidget().getLoading(context, rs, progressValue)
          : Column(
              children: [
                LinearPercentIndicator(
                  animateFromLastPercent: true,
                  animation: true,
                  lineHeight: rs.getSize(3),
                  percent: thisIndex / cards.length,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  progressColor: Theme.of(context).primaryColor,
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
                  height: rs.getSize(170),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        child: SlideTransition(
                          position: animationOffset,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: rs.getSize(30)),
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
                                            rs,
                                            text: tr('practiceSeveralTimes'),
                                            color: Theme.of(context).disabledColor,
                                          ),
                                        ),
                                        SizedBox(height: rs.getSize(20)),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            getSpeedBtn(isNormal: true),
                                            SizedBox(width: rs.getSize(20)),
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                CircularPercentIndicator(
                                                  radius: rs.getSize(30),
                                                  lineWidth: rs.getSize(4),
                                                  percent: controller.audioProgress,
                                                  animateFromLastPercent: true,
                                                  progressColor: Theme.of(context).primaryColor,
                                                  backgroundColor: Theme.of(context).cardColor,
                                                ),
                                                Theme(
                                                  data: Theme.of(context)
                                                      .copyWith(highlightColor: MyColors.navyLight),
                                                  child: IconButton(
                                                    iconSize: rs.getSize(60),
                                                    onPressed: () {
                                                      controller.playAudio();
                                                    },
                                                    icon: Icon(
                                                      Icons.play_arrow_rounded,
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: rs.getSize(20)),
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
                      )
                    : const SizedBox.shrink(),
              ],
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
      containerColor = Theme.of(context).primaryColorLight;
      borderColor = Theme.of(context).cardColor;
    } else {
      containerColor = Theme.of(context).cardColor;
      borderColor = Theme.of(context).primaryColor;
    }

    return GestureDetector(
      onTap: () {
        isNormal
            ? controller.changeAudioSpeedToggle(isNormal: true)
            : controller.changeAudioSpeedToggle(isNormal: false);
      },
      child: Container(
        width: rs.getSize(90),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          color: containerColor,
        ),
        padding: EdgeInsets.symmetric(vertical: rs.getSize(5)),
        child: Center(
          child: MyWidget().getTextWidget(rs,
              text: isNormal ? tr('normal') : tr('speedDown'),
              color: Theme.of(context).primaryColor,
              isBold: true),
        ),
      ),
    );
  }
}
