import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/lesson/lesson_card.dart';
import 'package:podo/screens/lesson/lesson_finish.dart';
import 'package:podo/state_manager/lesson_state_manager.dart';
import 'dart:math';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:scratcher/scratcher.dart';

class LessonFrame extends StatefulWidget {
  LessonFrame({Key? key}) : super(key: key);

  @override
  State<LessonFrame> createState() => _LessonFrameState();
}

class _LessonFrameState extends State<LessonFrame> {
  final lessonId = Get.arguments;
  int thisIndex = 0;
  ScrollPhysics scrollPhysics = const AlwaysScrollableScrollPhysics();
  final KO = 'ko';
  final PRONUN = 'pronun';
  final EX1 = 'ex1';
  final EX2 = 'ex2';
  final EX3 = 'ex3';
  final EX4 = 'ex4';
  String fo = 'en'; //todo: UserInfo 의 language 로 설정하기
  bool isLoading = true;

  //final _record = Record();
  List<LessonCard> cards = [];
  Map<int, GlobalKey<ScratcherState>> scratchKey = {};
  bool isScratchTextVisible = true;
  List<String> examples = [];
  late String answer;
  Color quizBorderColor = Colors.white;
  SwiperController swiperController = SwiperController();


  Widget getCards(int index) {
    LessonCard card = cards[index];
    String type = card.type;
    Widget widget;

    switch (type) {
      case MyStrings.subject:
        widget = Column(
          children: [
            Row(
              children: const [
                Icon(Icons.flag_outlined, size: 18),
                SizedBox(height: 10),
                Text(MyStrings.newExpression),
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
            )
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
                child: Html(
                  data: card.content[fo],
                  style: {
                    'html': Style(
                      fontSize: const FontSize(30),
                    )
                  },
                ),
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
                MyWidget().getTextWidget(text: MyStrings.listenAndRepeat),
              ],
            ),
            const SizedBox(height: 50),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      topBtns(index),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: MyWidget().getTextWidget(
                            text: card.content[KO], size: 30, color: Colors.black, isKorean: true),
                      ),
                      const SizedBox(height: 10),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: MyWidget().getTextWidget(
                            text: card.content[PRONUN], size: 20, color: Colors.black, isKorean: true),
                      ),
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

      case MyStrings.speaking:
        if (!scratchKey.containsKey(index)) {
          scratchKey[index] = GlobalKey<ScratcherState>();
        }
        widget = Column(
          children: [
            Row(
              children: [
                const Icon(Icons.speaker_phone_outlined, size: 18),
                const SizedBox(width: 8),
                MyWidget().getTextWidget(text: MyStrings.speakInKorean),
              ],
            ),
            const SizedBox(height: 50),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Listener(
                    onPointerDown: (event) {
                      setState(() {
                        scrollPhysics = const NeverScrollableScrollPhysics();
                        isScratchTextVisible = false;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Scratcher(
                          key: scratchKey[index],
                          color: MyColors.grey,
                          onScratchEnd: () {
                            setState(() {
                              scratchKey[index]!
                                  .currentState!
                                  .reset(duration: const Duration(milliseconds: 500));
                              scrollPhysics = const AlwaysScrollableScrollPhysics();
                              isScratchTextVisible = true;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            child: MyWidget().getTextWidget(
                              text: card.content[KO],
                              size: 30,
                              color: Colors.black,
                              isKorean: true,
                            ),
                          ),
                        ),
                        isScratchTextVisible
                            ? MyWidget().getTextWidget(
                                text: MyStrings.scratch,
                                color: MyColors.grey,
                                size: 12,
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
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
        bool hasKo;
        card.content[KO] == null ? hasKo = false : hasKo = true;
        widget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 18),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Offstage(
                    offstage: !hasKo,
                    child: hasKo
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: MyWidget().getTextWidget(text: card.content[KO], isKorean: true, size: 20),
                          )
                        : const SizedBox.shrink(),
                  ),
                  MyWidget().getTextWidget(text: card.content[fo], size: 20),
                ],
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
                MyWidget().getTextWidget(text: MyStrings.nativesTip),
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
        if(examples.isEmpty) {
          examples = [card.content[EX1], card.content[EX2], card.content[EX3], card.content[EX4]];
          answer = card.content[EX1];
          examples.shuffle(Random());
        }
        widget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.question_mark_rounded, size: 18),
                const SizedBox(width: 8),
                MyWidget().getTextWidget(text: MyStrings.takeQuiz),
              ],
            ),
            const SizedBox(height: 50),
            MyWidget().getTextWidget(text: card.content[KO], size: 15, color: Colors.black),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: examples.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if(examples[index] == answer) {
                          quizBorderColor = MyColors.purple;
                          Future.delayed(const Duration(seconds: 1), (){
                            swiperController.move(thisIndex+1);
                            quizBorderColor = Colors.white;
                          });
                        } else {
                          quizBorderColor = MyColors.red;
                          Future.delayed(const Duration(seconds: 1), (){
                            setState(() {
                              quizBorderColor = Colors.white;
                            });
                          });
                        }
                        //todo: 효과음 재생
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: quizBorderColor),
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
                          child: MyWidget()
                              .getTextWidget(text: '${index + 1}. ${examples[index]}', isKorean: true),
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

  @override
  void initState() {
    super.initState();
    Get.put(LessonStateManager);
    isLoading = true;
    Database()
        .getDocs(collection: 'Lessons/$lessonId/LessonCards', orderBy: 'orderId', descending: false)
        .then((value) => setState(() {
              for (dynamic map in value) {
                cards.add(LessonCard.fromJson(map));
              }
              isLoading = false;
            }));
  }

  // void initIndexChange() {
  //   player.dispose();
  //   if(cards[thisIndex].type == MyStrings.repeat) {
  //     player = AudioPlayer();
  //     player.positionStream.listen((position) {
  //       currentPosition = position;
  //       if(duration!.inMilliseconds > 0) {
  //         audioProgress = currentPosition.inMilliseconds / duration!.inMilliseconds;
  //         audioProgress = num.parse(audioProgress.toStringAsFixed(3)).toDouble();
  //       } else {
  //         audioProgress = 0.0;
  //       }
  //       if (audioProgress > 1) {
  //         audioProgress = 1;
  //       }
  //       update();
  //     });
  //
  //     player.playerStateStream.listen((event) {
  //       print('listener fired : ${event.processingState}');
  //       if (event.processingState == ProcessingState.completed) {
  //         print('끝!');
  //         direction = directionTexts2[practiceCount];
  //         audioProgress = 0;
  //         setResponseBtn(btn1: true);
  //         isAudioProgressActive = false;
  //         update();
  //       }
  //     });
  //   }
  //   audioProgress = 0.0;
  //   direction = MyStrings.swipe;
  //   isResponseBtn1Active = false;
  //   isResponseBtn2Active = false;
  //   isAudioProgressActive = false;
  //   practiceCount = 0;
  //   duration = const Duration(seconds: 0);
  //   currentPosition = const Duration(seconds: 0);
  // };
  // void changeIndex(int index) {
  //   //stopListener = true;
  //   thisIndex = index;
  //   LessonCard card = cards[thisIndex];
  //   initIndexChange();
  //   //update();
  //   //stopListener = false;
  //
  //   switch (card.type) {
  //     case MyStrings.subject:
  //       direction = MyStrings.swipe;
  //       update();
  //       break;
  //
  //     case MyStrings.explain:
  //       direction = MyStrings.swipe;
  //       update();
  //       break;
  //
  //     case MyStrings.repeat:
  //       direction = MyStrings.listen1;
  //       playRepeat();
  //       break;
  //
  //     case MyStrings.speak:
  //       direction = MyStrings.speakInKorean;
  //       playSpeak();
  //       break;
  //
  //     case MyStrings.quiz:
  //       direction = '';
  //       update();
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyWidget().getAppbar(
          context: context,
          title: MyStrings.title,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                      physics: scrollPhysics,
                      onIndexChanged: (index) {
                        setState(() {
                          thisIndex = index;
                        });
                        if (index >= cards.length) {
                          Get.to(const LessonFinish());
                          return;
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 50),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyWidget().getTextWidget(
                              text: 'controller.direction',
                              size: 15,
                              color: MyColors.grey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            // Visibility(
                            //   visible: controller.isAudioProgressActive,
                            //   child: CircularPercentIndicator(
                            //     radius: 10,
                            //     lineWidth: 3,
                            //     percent: controller.audioProgress,
                            //     progressColor: MyColors.purple,
                            //     animation: true,
                            //     animateFromLastPercent: true,
                            //   ),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // SizedBox(
                        //   height: 50,
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       Visibility(
                        //         visible: controller.isResponseBtn1Active,
                        //         child: IconButton(
                        //           onPressed: () async {
                        //             controller.practiceCount++;
                        //             if (type == MyStrings.repeat) {
                        //               controller.playRepeat();
                        //             } else if (type == MyStrings.speak) {
                        //               controller.playSpeak();
                        //               // if(await _record.hasPermission()) {
                        //               //   await _record.start();
                        //               //   print('hi');
                        //               // }
                        //             }
                        //           },
                        //           icon: type == MyStrings.repeat
                        //               ? getResponseIcon(Icons.check_circle)
                        //               : getResponseIcon(FontAwesomeIcons.microphone),
                        //           padding: EdgeInsets.zero,
                        //         ),
                        //       ),
                        //       Visibility(
                        //         visible: controller.isResponseBtn2Active,
                        //         child: Row(
                        //           children: [
                        //             IconButton(
                        //               onPressed: () {},
                        //               icon: getResponseIcon(Icons.replay_circle_filled_rounded),
                        //             ),
                        //             IconButton(
                        //               onPressed: () {},
                        //               icon: getResponseIcon(Icons.play_circle_filled_rounded),
                        //             ),
                        //             IconButton(
                        //               onPressed: () {},
                        //               icon: getResponseIcon(Icons.next_plan_rounded),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Icon getResponseIcon(IconData iconData) {
    return Icon(
      iconData,
      size: 50,
      color: MyColors.purple,
    );
  }

  Widget topBtns(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            // LessonCard card = cards[index];
            // _controller.setFavorite(index, !card.isFavorite!);
            // card.isFavorite!
            //     ? UserInfo().addFavorite(card.uniqueId)
            //     : UserInfo().removeFavorite(card.uniqueId);
          },
          icon: const Icon(
            Icons.star_rounded,
            //cards[index].isFavorite! ? Icons.star_rounded : Icons.star_outline_rounded,
            color: MyColors.purple,
            size: 30,
          ),
        ),
      ],
    );
  }

  Widget bottomDirection(String text, {bool hasCircleProgress = false}) {
    return Column(
      children: [
        const Divider(
          color: MyColors.grey,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyWidget().getTextWidget(
              text: text,
              size: 15,
              color: MyColors.grey,
            ),
            const SizedBox(
              width: 10,
            ),
            hasCircleProgress
                ? GetBuilder<LessonStateManager>(builder: (controller) {
                    return CircularPercentIndicator(
                      radius: 10,
                      lineWidth: 3,
                      percent: 0.5,
                      //_controller.audioProgress,
                      progressColor: MyColors.purple,
                      animation: true,
                      animateFromLastPercent: true,
                    );
                  })
                : const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}
