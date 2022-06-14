import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:podo/common_widgets/my_widget.dart';
import 'package:podo/lessons/lesson_card.dart';
import 'package:podo/user/user_info.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LessonFrame extends StatelessWidget {
  LessonFrame({Key? key}) : super(key: key);

  final _controller = Get.put(StateManager());

  void setBtns(int index) {
    _controller.cards[index].audio != null
        ? _controller.setPlayBtn(true)
        : _controller.setPlayBtn(false);

    UserInfo().favorites.contains('${_controller.cards[index].kr}/${_controller.cards[index].en}')
        ? _controller.setFavoriteBtn(true)
        : _controller.setFavoriteBtn(false);
  }

  @override
  Widget build(BuildContext context) {
    setBtns(_controller.thisIndex);

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
                  return getCards(_controller.cards[index]);
                },
                loop: false,
                itemCount: _controller.cards.length,
                viewportFraction: 0.8,
                scale: 0.8,
                onIndexChanged: (index) {
                  setBtns(index);
                  _controller.thisIndex = index;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: IconButton(
                onPressed: (){
                  _controller.isPlayBtnActive
                      ? null //todo: 오디오 재생
                      : null;
                },
                icon: GetBuilder<StateManager>(
                  builder: (_controller) {
                    return Icon(FontAwesomeIcons.play, color: _controller.playBtnColor,);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget favoriteBtn({bool hasSkipBtn = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            _controller.setFavoriteBtn(!_controller.isFavoriteClicked);
            String favorite = '${_controller.cards[_controller.thisIndex].kr}/${_controller.cards[_controller.thisIndex].en}';
            _controller.isFavoriteClicked
              ? UserInfo().addFavorite(favorite)
              : UserInfo().removeFavorite(favorite);
          },
          icon: GetBuilder<StateManager>(
            builder: (_controller) {
              return Icon(
                _controller.favoriteIcon,
                color: MyColors.purple,
                size: 30,
              );
            },
          ),
        ),
        hasSkipBtn
            ? TextButton(onPressed: (){}, child: MyWidget().getTextWidget(MyStrings.skip, 15, MyColors.grey))
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget bottomDirection(String text, {double? cpTime}) {
    return Column(
      children: [
        const Divider(
          color: MyColors.grey,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyWidget().getTextWidget(text, 15, MyColors.grey),
            // todo: 원형 프로그레스바 추가할 것
          ],
        ),
      ],
    );
  }

  Widget getCards(LessonCard card) {
    String type = card.type;
    Widget widget;

    switch (type) {
      case  MyStrings.subject :
        widget = Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            favoriteBtn(),
            MyWidget().getTextWidget(card.kr!, 30, Colors.black),
            MyWidget().getTextWidget(card.en!, 20, Colors.black),
            bottomDirection(MyStrings.swipe),
          ],
        );
        break;

      case MyStrings.explain :
        widget = Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              child: card.explain,
            ),
            bottomDirection(MyStrings.swipe),
          ],
        );
        break;

      case MyStrings.practice :
        widget = Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            favoriteBtn(hasSkipBtn: true),
            Column(
              children: [
                MyWidget().getTextWidget(card.kr!, 30, Colors.black),
                const SizedBox(height: 10,),
                MyWidget().getTextWidget(card.pronun!, 20, Colors.black),
              ],
            ),
            MyWidget().getTextWidget(card.en!, 20, Colors.black),
            bottomDirection(MyStrings.listen),
          ],
        );
        break;

      case MyStrings.speak :
        widget = Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            favoriteBtn(hasSkipBtn: true),
            MyWidget().getTextWidget(card.kr!, 30, Colors.black),
            MyWidget().getTextWidget(card.en!, 20, Colors.black),
            bottomDirection(MyStrings.speakInKorean),
          ],
        );
        break;

      case MyStrings.quiz :
        widget = Column(
          children: [
            favoriteBtn(hasSkipBtn: true),
            Expanded(
              child: Center(
                child: GridView.builder(
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
                        onTap: (){
                          //todo: 정답여부 판별
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              color: MyColors.purpleLight, //todo: 정답여부에 따라 변경하기
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Center(
                              child: MyWidget().getTextWidget(card.examples![index], 20, Colors.black),
                            )
                        ),
                      );
                    }
                ),
              ),
            ),
            bottomDirection(card.question!),
          ],
        );
        break;

      default:
        widget = const Text('widget');
    }


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: widget,
          )
      ),
    );
  }
}


class StateManager extends GetxController {
  List<LessonCard> cards = SampleLesson().getSampleLessons();
  bool isPlayBtnActive = true;
  Color playBtnColor = Colors.black;
  bool isFavoriteClicked = false;
  IconData favoriteIcon = Icons.star_outline_rounded;
  int thisIndex = 0;

  void setPlayBtn(bool isActive) {
    isPlayBtnActive = isActive;
    isPlayBtnActive ? playBtnColor = Colors.black : playBtnColor = MyColors.grey;
    update();
  }

  void setFavoriteBtn(bool isClicked) {
    isFavoriteClicked = isClicked;
    isFavoriteClicked ? favoriteIcon = Icons.star_rounded : favoriteIcon = Icons.star_outline_rounded;
    update();
  }
}

class SampleLesson {
  final LessonCard subjectSample = LessonCard('beginner_01', 0, MyStrings.subject, kr: '~후에', en: 'after~');
  final LessonCard explainSample = LessonCard('beginner_01', 1, MyStrings.explain, explain: Html(
      data: """<div>
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
  final LessonCard practiceSample = LessonCard('beginner_01', 2, MyStrings.practice, kr: '밥을 먹어요', pronun: '[바블머거요]', en: 'I have a meal', audio: 'practice.mp3');
  final LessonCard speakSample = LessonCard('beginner_01', 3, MyStrings.speak, kr: '학교에 가요', en: 'I go to school', audio: 'speak.mp3');
  final LessonCard quizSample = LessonCard('beginner_01', 4, MyStrings.quiz, question: 'Listen and click the answer', examples: ['ㄱ', 'ㄴ','ㄷ','ㄹ'], audio: 'quiz.mp3');

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