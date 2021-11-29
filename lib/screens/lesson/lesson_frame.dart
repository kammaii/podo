import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:podo/common_widgets/my_widget.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LessonFrame extends StatefulWidget {
  const LessonFrame({Key? key}) : super(key: key);

  @override
  _LessonFrameState createState() => _LessonFrameState();
}

class _LessonFrameState extends State<LessonFrame> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyWidget().getAppbar(MyStrings.title),
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
                  return getCards(index);
                },
                loop: false,
                itemCount: 3,
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

Widget getCards(int index) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 50),
    child: Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.star_outline_rounded,
                  color: MyColors.purple,
                  size: 30,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                getCardText('표현', 30),
                const SizedBox(
                  height: 20,
                ),
                getCardText('[발음]', 20),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: getCardText('영어뜻', 20),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget getCardText(String text, double size) {
  return MyWidget().getTextWidget(text, size, Colors.black);
}
