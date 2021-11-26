import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:podo/common_widgets/my_text_widget.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class LessonFinish extends StatelessWidget {
  const LessonFinish({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                color: Colors.white
              ),
              waveColor: MyColors.purple,
              boxBackgroundColor: MyColors.purpleLight,
              boxHeight: 100,
            ),
            const Divider(thickness: 1, indent: 30, endIndent: 30,),
            const SizedBox(height: 20,),
            MyTextWidget().getTextWidget(MyStrings.beginner, 20, MyColors.purple),
          ],
        ),
      ),
    );
  }
}
