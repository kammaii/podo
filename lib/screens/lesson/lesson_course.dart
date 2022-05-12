import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common_widgets/my_widget.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

import 'lesson_main.dart';

class LessonCourse extends StatelessWidget {
  const LessonCourse({Key? key}) : super(key: key);

  Widget getListItem(BuildContext context, int key, String title) {
    String sampleImage = 'assets/images/course_hangul.png';
    return Card(
      key: ValueKey(key),
      child: InkWell(
        onTap: () {
          print(key);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LessonMain(
                        course: title,
                        courseImage: sampleImage,

                      )));
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                      width: 80,
                      height: 80,
                      child: Hero(
                        child: Image.asset(sampleImage),
                        tag: 'courseImage:$title',
                      ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: MyWidget().getTextWidget(
                      title,
                      25,
                      MyColors.purple,
                      isBold: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              MyWidget().getTextWidget(
                MyStrings.lorem,
                15,
                MyColors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: MyWidget().getTextWidget(
                  MyStrings.selectCourse,
                  20,
                  MyColors.purple,
                  isBold: true,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  getListItem(context, 0, MyStrings.hangul),
                  getListItem(context, 1, MyStrings.beginner),
                  getListItem(context, 2, MyStrings.intermediate),
                  getListItem(context, 3, MyStrings.advanced)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
