import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/lesson/lesson.dart';
import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:podo/screens/writing/writing_list_main.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class WritingTopicMain extends StatelessWidget {
  WritingTopicMain({Key? key}) : super(key: key);

  LessonCourse course = Get.arguments;
  List<Lesson> lessons = [];
  final KO = 'ko';

  Widget lockedTopic(int index) {
    return Container(
        decoration: const BoxDecoration(
          color: MyColors.navyLight,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.lock,
                  size: 50,
                  color: MyColors.navyLight,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              child: MyWidget().getTextWidget(
                text: 'Lesson ${(index + 1).toString()}',
                color: MyColors.navy,
                isBold: true,
              ),
            )
          ],
        ));
  }

  Widget unlockedTopic(int index) {
    return InkWell(
      onTap: () {
        String lessonId = lessons[index].id;
        Get.to(WritingListMain(), arguments: lessonId);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: MyColors.navyLight,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyWidget().getTextWidget(
              text: 'Lesson ${(index + 1).toString()}',
              color: Colors.white,
              isBold: true,
              size: 18,
            ),
            MyWidget().getTextWidget(
              text: lessons[index].title[KO],
              color: MyColors.navy,
              size: 13,
              isBold: true,
              maxLine: 2,
              isTextAlignCenter: true,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    for (dynamic lesson in course.lessons) {
      if (lesson is Map) {
        lessons.add(Lesson.fromJson(lesson as Map<String, dynamic>));
      }
    }

    return SafeArea(
      child: Scaffold(
        appBar: MyWidget().getAppbar(title: MyStrings.writingTopics),
        body: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {},
                      child: const Text(MyStrings.myWritings, style: TextStyle(color: MyColors.purple))),
                ],
              ),
              MyWidget().getTextWidget(
                  text: MyStrings.unlockWritingTopics, isTextAlignCenter: true, color: MyColors.navy),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  //itemCount: lessons.length,
                  itemCount: 2,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 13,
                    mainAxisSpacing: 13,
                  ),
                  itemBuilder: (context, index) {
                    // String lessonId = lessons[index].id;
                    // Widget widget = lockedTopic(index);
                    // User().lessonRecord.forEach((key, value) {
                    //   if(value.contains(lessonId)) {
                    //     widget = unlockedTopic(index);
                    //   }
                    // });
                    // return widget;
                    if (index == 0) {
                      return unlockedTopic(index);
                    } else {
                      return lockedTopic(index);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
