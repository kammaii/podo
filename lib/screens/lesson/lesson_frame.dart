import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:podo/common_widgets/my_widget.dart';
import 'package:podo/common_widgets/play_audio.dart';
import 'package:podo/screens/lesson/lesson_card.dart';
import 'package:podo/screens/lesson/lesson_finish.dart';
import 'package:podo/user/user_info.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LessonFrame extends StatelessWidget {
  LessonFrame({Key? key}) : super(key: key);

  final _controller = Get.put(LessonFrameStateManager());

  @override
  Widget build(BuildContext context) {
    int totalCardNo = _controller.cards.length;

    return SafeArea(
      child: Scaffold(
        appBar: MyWidget().getAppbar(context, MyStrings.title),
        body: Column(
          children: [
            GetBuilder<LessonFrameStateManager>(
              builder: (_controller) {
                return LinearPercentIndicator(
                  animateFromLastPercent: true,
                  animation: true,
                  lineHeight: 3.0,
                  percent: _controller.thisIndex/totalCardNo,
                  backgroundColor: MyColors.navyLight,
                  progressColor: MyColors.purple,
                );
              },
            ),
            Expanded(
              child: Swiper(
                itemBuilder: (context, index) {
                  if(index < _controller.cards.length) {
                    return getCards(index);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
                loop: false,
                itemCount: _controller.cards.length+1,
                viewportFraction: 0.8,
                scale: 0.8,
                onIndexChanged: (index) {
                  _controller.thisIndex = index;
                  if(index >= _controller.cards.length) {
                    Get.to(const LessonFinish());
                    return;
                  }
                  LessonCard card = _controller.cards[_controller.thisIndex];
                  if(card.audio != null) {
                    _controller.setPlayBtn(true);
                    playAudio(card.audio!);
                  } else {
                    _controller.setPlayBtn(false);
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: IconButton(
                onPressed: (){
                  _controller.isPlayBtnActive
                      ? PlayAudio().playAudio(_controller.cards[_controller.thisIndex].audio!)
                      : null;
                },
                icon: GetBuilder<LessonFrameStateManager>(
                  builder: (_controller) {
                    return Icon(FontAwesomeIcons.play, color: _controller.isPlayBtnActive ? Colors.black : MyColors.grey,);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void playAudio(String audio) async{
    //await _audioPlayer.setSourceUrl(audio);
    PlayAudio().playAudio(audio);
  }

  Widget topBtns(int index, {bool hasFavoriteBtn = true, bool hasSkipBtn = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        hasFavoriteBtn
          ? IconButton(
              onPressed: () {
                LessonCard card = _controller.cards[index];
                _controller.setFavorite(index, !card.isFavorite!);
                card.isFavorite!
                  ? UserInfo().addFavorite(card.uniqueId)
                  : UserInfo().removeFavorite(card.uniqueId);
              },
              icon: GetBuilder<LessonFrameStateManager>(
                builder: (_controller) {
                  return Icon(
                    _controller.cards[index].isFavorite!
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                    color: MyColors.purple,
                    size: 30,
                  );
                },
              ),
            )
          : const SizedBox.shrink(),
      hasSkipBtn
          ? skipBtn()
          : const SizedBox.shrink(),
      ],
    );
  }

  Widget skipBtn() {
    return TextButton(onPressed: (){}, child: MyWidget().getTextWidget(MyStrings.skip, 15, MyColors.grey));
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
            const SizedBox(width: 10,),
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                value: 0.7,
                strokeWidth: 2.5,
                color: MyColors.purple,
                backgroundColor: MyColors.navyLight,
              ),
            )
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
      case  MyStrings.subject :
        widget = Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            topBtns(index, hasSkipBtn: false),
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
            topBtns(index),
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
            topBtns(index),
            MyWidget().getTextWidget(card.kr!, 30, Colors.black),
            MyWidget().getTextWidget(card.en!, 20, Colors.black),
            bottomDirection(MyStrings.speakInKorean),
          ],
        );
        break;

      case MyStrings.quiz :
        widget = Column(
          children: [
            topBtns(index, hasFavoriteBtn: false),
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


class LessonFrameStateManager extends GetxController {
  late List<LessonCard> cards;
  late bool isPlayBtnActive;
  late int thisIndex;

  void init() {
    cards = SampleLesson().getSampleLessons(); //todo: DB에서 해당 레슨카드 가져오기
    for (LessonCard card in cards) {
      UserInfo().favorites.contains(card.uniqueId)
          ? card.isFavorite = true
          : card.isFavorite = false;
    }
    cards[0].audio != null
      ? isPlayBtnActive = true
      : isPlayBtnActive = false;
    thisIndex = 0;
    update();
  }

  void setPlayBtn(bool isActive) {
    isPlayBtnActive = isActive;
    update();
  }

  void setFavorite(int index, bool isFavorite) {
    cards[index].isFavorite = isFavorite;
    update();
  }

  void setThisIndex(int index) {
    thisIndex = index;
    update();
  }
}

class SampleLesson {
  final LessonCard subjectSample = LessonCard('bgn_01', 0, MyStrings.subject, kr: '~후에', en: 'after~');
  final LessonCard explainSample = LessonCard('bgn_01', 1, MyStrings.explain, explain: Html(
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
  final LessonCard practiceSample = LessonCard('bgn_01', 2, MyStrings.practice, kr: '밥을 먹어요', pronun: '[바블머거요]', en: 'I have a meal', audio: 'sample.mp3');
  final LessonCard speakSample = LessonCard('bgn_01', 3, MyStrings.speak, kr: '학교에 가요', en: 'I go to school', audio: 'sample.mp3');
  final LessonCard quizSample = LessonCard('bgn_01', 4, MyStrings.quiz, question: 'Listen and click the answer', examples: ['ㄱ', 'ㄴ','ㄷ','ㄹ'], audio: 'sample.mp3');

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