import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/common/play_stop_icon.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/flashcard/flashcard_controller.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:scratcher/scratcher.dart';

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

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    today = '${now.year}-${now.month}-${now.day}';
    allCards = LocalStorage().flashcards;
    cards = allCards.where((card) => (card.dateReview != today)).toList();
    playStopIcon = PlayStopIcon(this, size: 50);
  }

  @override
  void dispose() {
    super.dispose();
    LocalStorage().setFlashcards();
    setPlayStopIcon(isForward: false);
  }

  void setPlayStopIcon({required bool isForward}) {
    if (isForward) {
      PlayAudio().playFlashcard(cards[0].audio, addStreamCompleted: (event) {
        if (event.processingState == ProcessingState.completed) {
          setPlayStopIcon(isForward: false);
          PlayAudio().stream.cancel();
        }
      });
      playStopIcon.clickIcon(isForward: true);
      isPlay = true;
    } else {
      PlayAudio().stop();
      playStopIcon.clickIcon(isForward: false);
      isPlay = false;
    }
  }

  void checkShuffle(bool? value) {
    setPlayStopIcon(isForward: false);
    controller.isShuffleChecked = value!;
    if (value) {
      cards.shuffle();
    } else {
      cards = allCards.where((card) => (card.dateReview != today)).toList();
    }
    controller.update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: MyColors.purple,
        ),
      ),
      body: SafeArea(
        child: GetBuilder<FlashCardController>(
          builder: (_) {
            if (cards.isNotEmpty) {
              FlashCard card = cards[0];
              setPlayStopIcon(isForward: true);
              return Column(
                children: [
                  LinearPercentIndicator(
                    animateFromLastPercent: true,
                    animation: true,
                    lineHeight: 3.0,
                    percent: (allCards.length - cards.length) / allCards.length,
                    backgroundColor: MyColors.navyLight,
                    progressColor: MyColors.purple,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          MyWidget().getCheckBox(
                              value: controller.isShuffleChecked,
                              onChanged: (value) {
                                checkShuffle(value);
                              }),
                          MyWidget().getTextWidget(text: tr('shuffle')),
                        ],
                      ),
                      MyWidget().getTextWidget(text: '${tr('today')} ${allCards.length - cards.length} / ${allCards.length}   '),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Center(
                                  child: MyWidget().getTextWidget(
                                    text: card.front,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Divider(height: 20),
                              Expanded(
                                child: Obx(
                                  () => Center(
                                    child: controller.isViewAllClicked.value
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                            child: MyWidget().getTextWidget(
                                              text: card.back,
                                              size: 20,
                                              color: MyColors.grey,
                                            ))
                                        : Scratcher(
                                            color: MyColors.grey,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                              child: MyWidget().getTextWidget(
                                                text: card.back,
                                                size: 20,
                                                color: MyColors.grey,
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
                                child: MyWidget()
                                    .getTextWidget(text: tr('viewAll'), color: MyColors.grey, size: 13),
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: MyWidget().getRoundBtnWidget(
                              text: tr('next'),
                              f: () {
                                setPlayStopIcon(isForward: false);
                                FlashCard? reviewedCard = allCards.firstWhere((card) => card.id == cards[0].id);
                                reviewedCard.dateReview = today;
                                cards.removeAt(0);
                                controller.update();
                              },
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
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyWidget().getTextWidget(
                        text: tr('flashCardReviewCompleted'),
                        isTextAlignCenter: true,
                        color: MyColors.purple,
                        size: 20),
                    const SizedBox(height: 30),
                    MyWidget().getRoundBtnWidget(
                        text: tr('reviewAgainTomorrow'),
                        f: () {
                          Get.back();
                        }),
                    const SizedBox(height: 10),
                    MyWidget().getRoundBtnWidget(
                        text: tr('wantReviewMore'),
                        bgColor: MyColors.pink,
                        f: () {
                          cards = [...allCards];
                          controller.update();
                        })
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
