import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class LessonComplete extends StatelessWidget {
  const LessonComplete({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double percent = 0.5;
    final ConfettiController controller = ConfettiController(duration: const Duration(seconds: 10));
    controller.play();

    return Scaffold(
      backgroundColor: MyColors.purpleLight,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image.asset('assets/images/bubble_top.png', fit: BoxFit.fill),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image.asset('assets/images/bubble_bottom.png', fit: BoxFit.fill),
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextLiquidFill(
                  loadDuration: const Duration(seconds: 2),
                  text: MyStrings.congratulations,
                  textStyle: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
                  waveColor: MyColors.purple,
                  boxBackgroundColor: MyColors.purpleLight,
                  boxHeight: 100,
                ),
                const Divider(
                  thickness: 1,
                  indent: 30,
                  endIndent: 30,
                ),
                const SizedBox(
                  height: 20,
                ),
                MyWidget().getTextWidget(
                  text: MyStrings.beginnerLevel,
                  size: 20,
                  color: MyColors.purple,
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularPercentIndicator(
                        animation: true,
                        animationDuration: 1200,
                        circularStrokeCap: CircularStrokeCap.round,
                        radius: 150.0,
                        lineWidth: 10.0,
                        percent: percent,
                        center: MyWidget().getTextWidget(
                          text: '${(percent * 100).toInt().toString()}%',
                          size: 30,
                          color: MyColors.purple,
                          isBold: true,
                        ),
                        progressColor: MyColors.purple,
                      ),
                      ConfettiWidget(
                        confettiController: controller,
                        blastDirectionality: BlastDirectionality.explosive,
                        shouldLoop: true,
                        gravity: 0.05,
                        colors: const [
                          MyColors.pink,
                          MyColors.mustardLight,
                          MyColors.navyLight,
                          MyColors.greenLight,
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      getCircleBtn(const Icon(FontAwesomeIcons.fileLines), MyStrings.summary),
                      getCircleBtn(const Icon(Icons.home_rounded), MyStrings.home),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget getCircleBtn(Icon icon, String text) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(
            color: MyColors.purple,
            width: 3,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(50),
          ),
        ),
        child: IconButton(
          icon: icon,
          iconSize: 40,
          color: MyColors.purple,
          onPressed: () {},
        ),
      ),
      const SizedBox(
        height: 5,
      ),
      MyWidget().getTextWidget(
        text: text,
        size: 17,
        color: MyColors.purple,
      )
    ],
  );
}
