import 'dart:io';
import 'package:blur/blur.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:podo/common/cloud_storage.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/common/play_stop_icon.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/flashcard/flashcard_controller.dart';

class FlashCardReview extends StatefulWidget {
  const FlashCardReview({Key? key}) : super(key: key);

  @override
  _FlashCardReviewState createState() => _FlashCardReviewState();
}

class _FlashCardReviewState extends State<FlashCardReview> with TickerProviderStateMixin {
  late List<FlashCard> allCards;
  late List<FlashCard> cards;
  final controller = Get.find<FlashCardController>();
  late String today;
  late PlayStopIcon playStopIcon;
  bool isPlay = false;
  late bool isLoading;
  late double progressValue;
  late Map<String, String> audioPaths;
  late ResponsiveSize rs;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    progressValue = 0.0;
    audioPaths = {};
    DateTime now = DateTime.now();
    today = '${now.year}-${now.month}-${now.day}';
    allCards = LocalStorage().flashcards;
    cards = allCards.where((card) => (card.dateReview != today)).toList();
    _cacheAudioFiles();
  }

  @override
  void dispose() {
    super.dispose();
    LocalStorage().setFlashcards();
    setPlayStopIcon(isForward: false);
  }

  Future<void> _cacheAudioFiles() async {
    for (FlashCard card in cards) {
      String? audio = card.audio;
      if (audio != null && !audioPaths.containsKey(audio)) {
        try {
          List<String> audioRegex = audio.split(RegExp(r'_+'));
          final File? file = await CloudStorage()
              .downloadAudio(folderName: audioRegex[0], folderId: audioRegex[1], fileId: audioRegex[2]);
          if (file != null) {
            audioPaths[audio] = file.path;
            print(audioPaths);
          }
          if (audioPaths.length >= 5) {
            break;
          }
        } catch (e) {
          print('Error: $e');
        }
      }
    }
    if (isLoading) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void setPlayStopIcon({required bool isForward}) async {
    AudioPlayer player = PlayAudio().player;
    player.stop();
    if (isForward) {
      String? fileName = cards[0].audio;
      if (fileName != null && audioPaths.containsKey(fileName)) {
        playStopIcon.clickIcon(isForward: true);
        isPlay = true;
        String path = audioPaths[fileName]!;
        if (Platform.isIOS) {
          player.setFilePath('$path.m4a');
        } else {
          player.setFilePath(path);
        }
        await player.setVolume(1);
        player.playerStateStream.listen((event) {
          if (event.processingState == ProcessingState.completed) {
            setPlayStopIcon(isForward: false);
            PlayAudio().stream.cancel();
          }
        });
        player.play();
      }
    } else {
      playStopIcon.clickIcon(isForward: false);
      isPlay = false;
    }
  }

  void checkShuffle(bool? value) {
    setPlayStopIcon(isForward: false);
    controller.isShuffleChecked = value!;
    audioPaths.clear();
    isLoading = true;
    setState(() {
      if (value) {
        cards.shuffle();
      } else {
        cards = allCards.where((card) => (card.dateReview != today)).toList();
      }
      _cacheAudioFiles();
    });
  }

  Widget getBtn(String title, IconData icon, Function() fn) {
    return Row(children: [
      Expanded(
          child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: Theme.of(context).primaryColor),
            ),
            backgroundColor: Theme.of(context).cardColor),
        onPressed: fn,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: rs.getSize(10), vertical: rs.getSize(13)),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: rs.getSize(20)),
              SizedBox(width: rs.getSize(30)),
              Expanded(
                  child: Center(
                      child: MyWidget()
                          .getTextWidget(rs, text: title, size: 18, color: Theme.of(context).primaryColor))),
            ],
          ),
        ),
      ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    rs = ResponsiveSize(context);
    playStopIcon = PlayStopIcon(rs, this, size: 50);

    return Scaffold(
      appBar: MyWidget().getAppbar(context, rs, title: ''),
      body: isLoading
          ? Center(child: SpinKitThreeBounce(color: Theme.of(context).primaryColor, size: rs.getSize(20)))
          : GetBuilder<FlashCardController>(
            builder: (_) {
              if (cards.isNotEmpty) {
                FlashCard card = cards[0];
                setPlayStopIcon(isForward: true);
                return Column(
                  children: [
                    LinearPercentIndicator(
                      animateFromLastPercent: true,
                      animation: true,
                      lineHeight: rs.getSize(3),
                      percent: (allCards.length - cards.length) / allCards.length,
                      backgroundColor: Theme.of(context).primaryColorLight,
                      progressColor: Theme.of(context).primaryColor,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            MyWidget().getCheckBox(rs, value: controller.isShuffleChecked, onChanged: (value) {
                              checkShuffle(value);
                            }),
                            MyWidget().getTextWidget(rs,
                                text: tr('shuffle'), color: Theme.of(context).secondaryHeaderColor),
                          ],
                        ),
                        MyWidget().getTextWidget(rs,
                            text: '${tr('today')} ${allCards.length - cards.length} / ${allCards.length}   ',
                            color: Theme.of(context).secondaryHeaderColor),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration:
                              BoxDecoration(borderRadius: BorderRadius.circular(20), color: Theme.of(context).cardColor),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: MyWidget().getTextWidget(
                                      rs,
                                      text: card.front,
                                      size: 20,
                                      color: Theme.of(context).secondaryHeaderColor,
                                    ),
                                  ),
                                ),
                                const Divider(height: 20),
                                Expanded(
                                  child: Obx(
                                    () => Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                        child: controller.isViewAllClicked.value
                                            ? MyWidget().getTextWidget(
                                                rs,
                                                text: card.back,
                                                size: 20,
                                                color: Theme.of(context).disabledColor,
                                              )
                                            : Blur(
                                                blur: 2.3,
                                                child: MyWidget().getTextWidget(
                                                  rs,
                                                  text: card.back,
                                                  size: 20,
                                                  color: Theme.of(context).disabledColor,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTapDown: (_) {
                                    controller.isViewAllClicked.value = true;
                                  },
                                  onTapUp: (_) {
                                    controller.isViewAllClicked.value = false;
                                  },
                                  child: MyWidget().getTextWidget(rs,
                                      text: tr('makeClear'), color: Theme.of(context).disabledColor, size: rs.getSize(13)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: card.audio == null ? 0 : 1,
                      child: GestureDetector(
                        onTap: () {
                          if (isPlay) {
                            setPlayStopIcon(isForward: false);
                          } else {
                            setPlayStopIcon(isForward: true);
                          }
                        },
                        child: playStopIcon.icon,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: rs.getSize(20)),
                              child: MyWidget().getRoundBtnWidget(
                                rs,
                                text: tr('next'),
                                f: () {
                                  setPlayStopIcon(isForward: false);
                                  FlashCard? reviewedCard =
                                      allCards.firstWhere((card) => card.id == cards[0].id);
                                  reviewedCard.dateReview = today;
                                  cards.removeAt(0);
                                  audioPaths.remove(reviewedCard.audio);
                                  controller.update();
                                  if (audioPaths.length < 4) {
                                    _cacheAudioFiles();
                                  }
                                },
                                bgColor: Theme.of(context).primaryColor,
                                fontColor: Theme.of(context).cardColor
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyWidget().getTextWidget(rs,
                          text: tr('flashCardReviewCompleted'),
                          isTextAlignCenter: true,
                          color: Theme.of(context).primaryColor,
                          size: 20),
                      const SizedBox(height: 30),
                      getBtn(tr('reviewAgainTomorrow'), CupertinoIcons.paperplane, () => Get.back()),
                      const SizedBox(height: 20),
                      getBtn(tr('wantReviewMore'), Icons.refresh_rounded, () {
                        cards = [...allCards];
                        if (controller.isShuffleChecked) {
                          checkShuffle(true);
                        }
                        setState(() {
                          isLoading = true;
                        });
                        _cacheAudioFiles();
                      }),
                    ],
                  ),
                );
              }
            },
          ),
    );
  }
}
