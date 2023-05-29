import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_Stop_icon.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/flashcard/flashcard_controller.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:scratcher/scratcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlashCardReview extends StatefulWidget {
  const FlashCardReview({Key? key}) : super(key: key);

  @override
  _FlashCardReviewState createState() => _FlashCardReviewState();
}

class _FlashCardReviewState extends State<FlashCardReview> with TickerProviderStateMixin {
  List<FlashCard> allCards = Get.arguments;
  late List<FlashCard> cards;
  final controller = Get.find<FlashCardController>();
  final REVIEWED_DATE = 'reviewedDate';
  final REVIEWED_CARDS = 'reviewedCards';
  late SharedPreferences prefs;
  late List<String> reviewedCards;
  late String today;
  bool isViewAllClicked = false;
  late PlayStopIcon playStopIcon;
  late FlashCard card;

  @override
  void initState() {
    super.initState();
    playStopIcon = PlayStopIcon(this, size: 50);
  }

  @override
  void dispose() {
    super.dispose();
    setPlayStopIcon(isForward: false);
  }

  void setPlayStopIcon({required bool isForward}) {
    if (isForward) {
      PlayAudio().playFlashcard(card.audio, addStreamCompleted: (event) {
        if (event.processingState == ProcessingState.completed) {
          setPlayStopIcon(isForward: false);
          PlayAudio().stream.cancel();
        }
      });
      playStopIcon.clickIcon(isForward: true);
      card.isPlay = true;
    } else {
      PlayAudio().stop();
      playStopIcon.clickIcon(isForward: false);
      card.isPlay = false;
    }
  }

  void checkShuffle(bool? value) {
    PlayAudio().stop();
    setPlayStopIcon(isForward: false);
    controller.isShuffleChecked = value!;
    if (value) {
      cards.shuffle();
    } else {
      cards = allCards.where((card) => !reviewedCards.contains(card.id)).toList();
    }
    controller.update();
  }

  void onNextBtn() {
    reviewedCards.add(cards[0].id);
    prefs.setString(REVIEWED_DATE, today);
    prefs.setStringList(REVIEWED_CARDS, reviewedCards);
    cards.removeAt(0);
    controller.update();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
        body: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            DateTime now = DateTime.now();
            today = '${now.year}-${now.month}-${now.day}';

            if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
              prefs = snapshot.data;
              String? prefsDate = prefs.getString(REVIEWED_DATE);
              List<String>? prefsCards = prefs.getStringList(REVIEWED_CARDS);
              if (prefsDate != null && prefsDate == today) {
                prefsCards != null ? reviewedCards = [...prefsCards] : reviewedCards = [];
                cards = allCards.where((card) => !reviewedCards.contains(card.id)).toList();
              } else {
                reviewedCards = [];
                cards = [...allCards];
              }
              return GetBuilder<FlashCardController>(
                builder: (_) {
                  if (cards.isNotEmpty) {
                    card = cards[0];
                    setPlayStopIcon(isForward: true);
                    return Column(
                      children: [
                        LinearPercentIndicator(
                          animateFromLastPercent: true,
                          animation: true,
                          lineHeight: 3.0,
                          percent: reviewedCards.length / allCards.length,
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
                                MyWidget().getTextWidget(text: MyStrings.shuffle),
                              ],
                            ),
                            MyWidget().getTextWidget(
                                text: '${MyStrings.today} ${reviewedCards.length} / ${allCards.length}   '),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration:
                                  BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
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
                                      child: Center(
                                        child: isViewAllClicked
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
                                    GestureDetector(
                                      onTapDown: (_) {
                                        isViewAllClicked = true;
                                        controller.update();
                                      },
                                      onTapUp: (_) {
                                        isViewAllClicked = false;
                                        controller.update();
                                      },
                                      child: MyWidget()
                                          .getTextWidget(text: MyStrings.viewAll, color: MyColors.grey, size: 13),
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
                              if (card.isPlay) {
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
                          child: MyWidget().getRoundBtnWidget(
                            isRequest: false,
                            text: MyStrings.next,
                            bgColor: MyColors.purple,
                            fontColor: Colors.white,
                            f: () {
                              onNextBtn();
                            },
                            horizontalPadding: 20,
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
                              text: MyStrings.flashCardReviewCompleted,
                              isTextAlignCenter: true,
                              color: MyColors.purple,
                              size: 20),
                          const SizedBox(height: 30),
                          MyWidget().getRoundBtnWidget(
                              isRequest: false,
                              text: MyStrings.reviewAgainTomorrow,
                              bgColor: MyColors.purple,
                              fontColor: Colors.white,
                              f: () {
                                Get.back();
                              })
                        ],
                      ),
                    );
                  }
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
