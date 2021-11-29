import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:podo/common_widgets/my_widget.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class LessonFinish extends StatelessWidget {
  const LessonFinish({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double percent = 0.5;

    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColors.purpleLight,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextLiquidFill(
              loadDuration: const Duration(seconds: 2),
              text: MyStrings.congratulations,
              textStyle: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
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
              MyStrings.beginnerLevel,
              20,
              MyColors.purple,
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularPercentIndicator(
                    animation: true,
                    animationDuration: 1200,
                    circularStrokeCap: CircularStrokeCap.round,
                    radius: 200.0,
                    lineWidth: 10.0,
                    percent: percent,
                    center: MyWidget().getTextWidget(
                      '${(percent * 100).toInt().toString()}%',
                      30,
                      MyColors.purple,
                      isBold: true
                    ),
                    progressColor: MyColors.purple,
                  ),
                  Image.asset('assets/images/confetti.png'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  getCircleBtn(const Icon(FontAwesomeIcons.fileAlt), MyStrings.summary),
                  getCircleBtn(const Icon(Icons.home_rounded), MyStrings.home),
                ],
              ),
            )
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
          borderRadius: const BorderRadius.all(Radius.circular(50),),
        ),
        child: IconButton(
          icon: icon,
          iconSize: 40,
          color: MyColors.purple,
          onPressed: (){},
        ),
      ),
      const SizedBox(height: 5,),
      MyWidget().getTextWidget(text, 17, MyColors.purple)
    ],
  );
}
