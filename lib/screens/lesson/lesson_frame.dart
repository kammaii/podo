import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/lesson/lesson_card.dart';
import 'package:podo/screens/lesson/lesson_finish.dart';
import 'package:podo/state_manager/lesson_state_manager.dart';
import 'package:podo/items/user_info.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:scratcher/scratcher.dart';

class LessonFrame extends StatelessWidget {
  LessonFrame({Key? key}) : super(key: key);

  final _controller = Get.find<LessonStateManager>();
  final _scratchKey = GlobalKey<ScratcherState>();

  //final _record = Record();

  @override
  Widget build(BuildContext context) {
    int totalCardNo = _controller.cards.length;

    return SafeArea(
      child: Scaffold(
        appBar: MyWidget().getAppbar(
          context: context,
          title: MyStrings.title,
        ),
        body: GetBuilder<LessonStateManager>(
          builder: (controller) {
            String type = controller.cards[controller.thisIndex].type;

            return Column(
              children: [
                LinearPercentIndicator(
                  animateFromLastPercent: true,
                  animation: true,
                  lineHeight: 3.0,
                  percent: controller.thisIndex / totalCardNo,
                  backgroundColor: MyColors.navyLight,
                  progressColor: MyColors.purple,
                ),
                Expanded(
                  child: Swiper(
                    itemBuilder: (context, index) {
                      if (index < _controller.cards.length) {
                        return getCards(index);
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                    loop: false,
                    itemCount: _controller.cards.length + 1,
                    viewportFraction: 0.8,
                    scale: 0.8,
                    physics: _controller.scrollPhysics,
                    onIndexChanged: (index) {
                      _controller.changeIndex(index);
                      if (index >= _controller.cards.length) {
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
                            text: controller.direction,
                            size: 15,
                            color: MyColors.grey,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Visibility(
                            visible: controller.isAudioProgressActive,
                            child: CircularPercentIndicator(
                              radius: 10,
                              lineWidth: 3,
                              percent: controller.audioProgress,
                              progressColor: MyColors.purple,
                              animation: true,
                              animateFromLastPercent: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Visibility(
                              visible: controller.isResponseBtn1Active,
                              child: IconButton(
                                onPressed: () async {
                                  controller.practiceCount++;
                                  if (type == MyStrings.repeat) {
                                    controller.playRepeat();
                                  } else if (type == MyStrings.speak) {
                                    controller.playSpeak();
                                    // if(await _record.hasPermission()) {
                                    //   await _record.start();
                                    //   print('hi');
                                    // }
                                  }
                                },
                                icon: type == MyStrings.repeat
                                    ? getResponseIcon(Icons.check_circle)
                                    : getResponseIcon(FontAwesomeIcons.microphone),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            Visibility(
                              visible: controller.isResponseBtn2Active,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: getResponseIcon(Icons.replay_circle_filled_rounded),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: getResponseIcon(Icons.play_circle_filled_rounded),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: getResponseIcon(Icons.next_plan_rounded),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          },
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
      children: [
        IconButton(
          onPressed: () {
            LessonCard card = _controller.cards[index];
            _controller.setFavorite(index, !card.isFavorite!);
            card.isFavorite!
                ? UserInfo().addFavorite(card.uniqueId)
                : UserInfo().removeFavorite(card.uniqueId);
          },
          icon: GetBuilder<LessonStateManager>(
            builder: (controller) {
              return Icon(
                controller.cards[index].isFavorite! ? Icons.star_rounded : Icons.star_outline_rounded,
                color: MyColors.purple,
                size: 30,
              );
            },
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
                      percent: _controller.audioProgress,
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

  Widget getCards(int index) {
    LessonCard card = _controller.cards[index];
    String type = card.type;
    Widget widget;

    switch (type) {
      case MyStrings.subject:
        widget = Column(
          children: [
            topBtns(index),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MyWidget().getTextWidget(
                    text: card.kr!,
                    size: 30,
                    color: Colors.black,
                  ),
                  MyWidget().getTextWidget(
                    text: card.en!,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              child: card.explain,
            ),
          ],
        );
        break;

      case MyStrings.repeat:
        widget = Column(
          children: [
            topBtns(index),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      MyWidget().getTextWidget(
                        text: card.kr!,
                        size: 30,
                        color: Colors.black,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      MyWidget().getTextWidget(
                        text: card.pronun!,
                        size: 20,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  MyWidget().getTextWidget(
                    text: card.en!,
                    size: 20,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ],
        );
        break;

      case MyStrings.speak:
        widget = Column(
          children: [
            topBtns(index),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Listener(
                    onPointerDown: (event) {
                      _controller.scrollPhysics = const NeverScrollableScrollPhysics();
                      _controller.update();
                    },
                    child: Scratcher(
                      key: _scratchKey,
                      color: MyColors.grey,
                      onScratchEnd: () {
                        _scratchKey.currentState!.reset(duration: const Duration(milliseconds: 500));
                        _controller.scrollPhysics = const AlwaysScrollableScrollPhysics();
                        _controller.update();
                      },
                      child: MyWidget().getTextWidget(
                        text: card.kr!,
                        size: 30,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  MyWidget().getTextWidget(
                    text: card.en!,
                    size: 20,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ],
        );
        break;

      case MyStrings.quiz:
        widget = Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MyWidget().getTextWidget(text: card.question!, size: 15, color: Colors.black),
            const SizedBox(height: 10),
            GridView.builder(
                shrinkWrap: true,
                itemCount: card.examples!.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      //todo: 정답여부 판별
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          color: MyColors.purpleLight, //todo: 정답여부에 따라 변경하기
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: MyWidget().getTextWidget(
                            text: card.examples![index],
                            size: 20,
                            color: Colors.black,
                          ),
                        )),
                  );
                }),
          ],
        );
        break;

      default:
        widget = const Text('widget');
    }

    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Card(
          child: Padding(
        padding: const EdgeInsets.all(10),
        child: widget,
      )),
    );
  }
}

class SampleLesson {
  final LessonCard subjectSample =
      LessonCard(lessonId: 'bgn_01', orderId: 0, type: MyStrings.subject, kr: '~후에', en: 'after~');
  final LessonCard explainSample =
      LessonCard(lessonId: 'bgn_01', orderId: 1, type: MyStrings.explain, explain: Html(data: """<div>
        <h1>Demo Page</h1>
        <p>This is a fantastic product that you should buy!</p>
        <h3>Features</h3>
        <ul>
          <li>It actually works</li>
          <li>It exists</li>
          <li>It doesn't cost much!</li>
        </ul>
        <!--You can pretty much put any html in here!-->
      </div>"""));
  final LessonCard practiceSample = LessonCard(
      lessonId: 'bgn_01',
      orderId: 2,
      type: MyStrings.repeat,
      kr: '밥을 먹어요',
      pronun: '[바블머거요]',
      en: 'I have a meal',
      audio: 'sample.mp3');
  final LessonCard speakSample = LessonCard(
      lessonId: 'bgn_01',
      orderId: 3,
      type: MyStrings.speak,
      kr: '학교에 가요',
      en: 'I go to school',
      audio: 'sample.mp3');
  final LessonCard quizSample = LessonCard(
      lessonId: 'bgn_01',
      orderId: 4,
      type: MyStrings.quiz,
      question: 'Listen and click the answer',
      examples: ['ㄱ', 'ㄴ', 'ㄷ', 'ㄹ'],
      audio: 'sample.mp3');

  List<LessonCard> getSampleLessons() {
    List<LessonCard> cards = [];
    cards.add(subjectSample);
    cards.add(explainSample);
    cards.add(practiceSample);
    cards.add(speakSample);
    cards.add(quizSample);
    return cards;
  }
}
