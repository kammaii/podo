import 'dart:math';
import 'package:animated_icon/animated_icon.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:podo/common/cloud_storage.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/lesson/lesson_card.dart';
import 'package:podo/screens/lesson/lesson_controller.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:scratcher/scratcher.dart';

class LessonFrame extends StatefulWidget {
  LessonFrame({Key? key}) : super(key: key);

  @override
  State<LessonFrame> createState() => _LessonFrameState();
}

class _LessonFrameState extends State<LessonFrame> with SingleTickerProviderStateMixin {
  final lesson = Get.arguments;
  int thisIndex = 0;
  ScrollPhysics scrollPhysics = const AlwaysScrollableScrollPhysics();
  final controller = Get.put(LessonController());
  final KO = 'ko';
  final PRONUN = 'pronun';
  final EX1 = 'ex1';
  final EX2 = 'ex2';
  final EX3 = 'ex3';
  final EX4 = 'ex4';
  final AUDIO = 'audio';
  final FILE_NAME = 'fileName';
  final SPEAKING = 'speaking';
  String fo = 'en'; //todo: UserInfo 의 language 로 설정하기
  bool isLoading = true;
  List<LessonCard> cards = [];
  Map<int, GlobalKey<ScratcherState>> scratchKey = {};
  bool isScratchTextVisible = true;
  List<String> examples = [];
  late String answer;
  int selectedAnswer = -1;
  Color quizBorderColor = Colors.white;
  SwiperController swiperController = SwiperController();
  Map<String, String> audios = {};
  late AnimationController animationController;
  late Animation<Offset> animationOffset;
  late Widget bottomWidget;

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
                child: Html(
                  data: card.content[fo],
                  style: {
                    'p': Style(
                        fontFamily: 'EnglishFont',
                        fontSize: const FontSize(15),
                        lineHeight: LineHeight.number(1.5)),
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
                                          audio: 'LessonAudios_${lesson.id}_${card.content[AUDIO]}');
                                      controller.hasFlashcard[card.id] = true;
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
                const Icon(Icons.emoji_emotions_outlined, size: 18),
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
                              scratchKey[index]!.currentState!.reset(duration: const Duration(milliseconds: 500));
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
        if (index == thisIndex) {}
        if (examples.isEmpty) {
          examples = [card.content[EX1], card.content[EX2], card.content[EX3], card.content[EX4]];
          answer = card.content[EX1];
          examples.shuffle(Random());
        }
        widget = Listener(
          onPointerDown: (event) {
            setState(() {
              scrollPhysics = const NeverScrollableScrollPhysics();
            });
          },
          child: Column(
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
                          selectedAnswer = index;
                          if (examples[index] == answer) {
                            scrollPhysics = const AlwaysScrollableScrollPhysics();
                            quizBorderColor = MyColors.purple;
                            Future.delayed(const Duration(seconds: 1), () {
                              swiperController.move(thisIndex + 1);
                              quizBorderColor = Colors.white;
                            });
                          } else {
                            quizBorderColor = MyColors.red;
                            Future.delayed(const Duration(seconds: 1), () {
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
          ),
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

  void animationListener() {
    bottomWidget = const SizedBox.shrink();
  }

  setBottomWidget() {
    animationController.removeListener(animationListener);
    LessonCard card = cards[thisIndex];
    if (card.content.containsKey(AUDIO)) {
      bottomWidget = Column(
        children: [
          MyWidget().getTextWidget(
            text: MyStrings.practice3Times,
            size: 15,
            color: MyColors.grey,
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
      toggleBottomAudioWidget(true);
    } else if (card.type == SPEAKING) {
      //todo: 클로바 실행
      bottomWidget = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MyWidget().getTextWidget(
            text: MyStrings.imListening,
            size: 15,
            color: MyColors.grey,
          ),
          const SizedBox(height: 20),
          AnimateIcon(
            onTap: () {},
            iconType: IconType.continueAnimation,
            animateIcon: AnimateIcons.activity,
            color: MyColors.purple,
            height: 70,
            width: 70,
          ),
        ],
      );
      toggleBottomAudioWidget(true);
    } else {
      animationController.addListener(animationListener);
      toggleBottomAudioWidget(false);
    }
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    bottomWidget = const SizedBox.shrink();

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
      CloudStorage().getLessonAudios(lessonId: lesson.id),
    ]).then((snapshots) {
      setState(() {
        Map<String, bool> flashcardMap = {};
        for (dynamic snapshot in snapshots[0]) {
          LessonCard card = LessonCard.fromJson(snapshot.data() as Map<String, dynamic>);
          if(card.type == MyStrings.repeat) {
            flashcardMap[card.id] = LocalStorage().hasFlashcard(itemId: card.id);
          }
          cards.add(card);
        }
        controller.hasFlashcard.value = flashcardMap.obs;
        for (dynamic snapshot in snapshots[1]) {
          audios.addAll(snapshot);
        }
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setBottomWidget();
      });
    }

    return Scaffold(
      appBar: MyWidget().getAppbar(title: lesson.title[KO], isKorean: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Stack(
                children: [
                  Column(
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
                            if (index >= cards.length) {
                              Get.toNamed(MyStrings.routeLessonComplete, arguments: lesson);
                              return;
                            } else {
                              setState(() {
                                thisIndex = index;
                                PlayAudio().player.stop();
                                if (cards[thisIndex].content.containsKey(AUDIO)) {
                                  String fileName = cards[thisIndex].content[AUDIO];
                                  if (audios.containsKey(fileName)) {
                                    controller.setAudioUrlAndPlay(url: audios[fileName]!);
                                  }
                                }
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 170),
                    ],
                  ),
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
                              return bottomWidget;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
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
              text: isNormal ? MyStrings.normal : MyStrings.speedDown, color: MyColors.purple, isBold: true),
        ),
      ),
    );
  }
}
