import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:podo/common_widgets/my_widget.dart';
import 'package:podo/lessons/lesson_card.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LessonFrame extends StatefulWidget {
  const LessonFrame({Key? key}) : super(key: key);

  @override
  _LessonFrameState createState() => _LessonFrameState();
}

class _LessonFrameState extends State<LessonFrame> {

  LessonCard subjectSample = LessonCard('beginner_01', 0, MyStrings.subject, kr: '~후에', en: 'after~');
  LessonCard explainSample = LessonCard('beginner_01', 1, MyStrings.explain, explain: [MyStrings.lorem, MyStrings.lorem]);
  LessonCard practiceSample = LessonCard('beginner_01', 2, MyStrings.practice, kr: '밥을 먹어요', pronun: '[바블머거요]', en: 'I have a meal', audio: 'practice.mp3');
  LessonCard speakSample = LessonCard('beginner_01', 3, MyStrings.speak, kr: '학교에 가요', en: 'I go to school', audio: 'speak.mp3');
  LessonCard quizSample = LessonCard('beginner_01', 4, MyStrings.quiz, question: '기역', examples: ['ㄱ', 'ㄴ','ㄷ','ㄹ'], audio: 'quiz.mp3');

  List<LessonCard> cards = [];


  @override
  void initState() {
    super.initState();
    cards.add(subjectSample);
    cards.add(explainSample);
    cards.add(practiceSample);
    cards.add(speakSample);
    cards.add(quizSample);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyWidget().getAppbar(context, MyStrings.title),
        body: Column(
          children: [
            LinearPercentIndicator(
              animateFromLastPercent: true,
              animation: true,
              lineHeight: 3.0,
              percent: 0.5,
              backgroundColor: MyColors.navyLight,
              progressColor: MyColors.purple,
            ),
            Expanded(
              child: Swiper(
                itemBuilder: (context, index) {
                  return getCards(cards[index]);
                },
                loop: false,
                itemCount: cards.length,
                viewportFraction: 0.7,
                scale: 0.7,
                onIndexChanged: (index) {},
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: Icon(FontAwesomeIcons.play),
            ),
          ],
        ),
      ),
    );
  }
}

Widget favoriteBtn({bool hasSkipBtn = false}) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            debugPrint('favorite clicked');
          },
          icon: const Icon(
            Icons.star_outline_rounded,
            color: MyColors.purple,
            size: 30,
          ),
        ),
        hasSkipBtn
            ? TextButton(onPressed: (){}, child: MyWidget().getTextWidget(MyStrings.skip, 10, MyColors.grey))
            : const SizedBox.shrink(),
      ],
    ),
  );
}

Widget bottomDirection(String text, {double? cpTime}) {
  return Row(
    children: [
      Text(text),
      // todo: 원형 프로그레스바 추가할 것
    ],
  );
}


Widget getCards(LessonCard card) {
  String type = card.type;
  Widget widget;

  switch (type) {
    case  MyStrings.subject :
      widget = Column(
        children: [
          favoriteBtn(),
          MyWidget().getTextWidget(card.kr!, 20, Colors.black),
          MyWidget().getTextWidget(card.en!, 15, Colors.black),
          bottomDirection(MyStrings.swipe),
        ],
      );
      break;

    case MyStrings.explain :
      List<Text> textWidgets = [];
      for(String explain in card.explain!) {
        textWidgets.add(MyWidget().getTextWidget('- $explain', 15, Colors.black));
      }
      widget = Column(
        children: textWidgets,
      );
      break;

    case MyStrings.practice :
      widget = Column(
        children: [
          favoriteBtn(hasSkipBtn: true),
          MyWidget().getTextWidget(card.kr!, 20, Colors.black),
          MyWidget().getTextWidget(card.pronun!, 15, Colors.black),
          MyWidget().getTextWidget(card.en!, 15, Colors.black),
          bottomDirection(MyStrings.listen),
        ],
      );
      break;

    case MyStrings.speak :
      widget = Column(
        children: [
          favoriteBtn(hasSkipBtn: true),
          MyWidget().getTextWidget(card.kr!, 20, Colors.black),
          MyWidget().getTextWidget(card.en!, 15, Colors.black),
          bottomDirection(MyStrings.speakInKorean),
        ],
      );
      break;

    case MyStrings.quiz :
      widget = Column(
        children: [
          favoriteBtn(hasSkipBtn: true),
          //todo: sliver 추가
          IconButton(onPressed: (){}, icon: const Icon(Icons.volume_up_rounded)),
          bottomDirection(MyStrings.listenAndClickAnswer),
        ],
      );
      break;

    default:
      widget = const Text('widget');
  }


  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 50),
    child: Card(
      child: widget
    ),
  );
}

Widget getCardText(String text, double size) {
  return MyWidget().getTextWidget(text, size, Colors.black);
}
