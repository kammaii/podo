import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'lesson_main.dart';

class LessonCourseMain extends StatefulWidget {
  LessonCourseMain({Key? key}) : super(key: key);

  @override
  State<LessonCourseMain> createState() => _LessonCourseMainState();
}

class _LessonCourseMainState extends State<LessonCourseMain> {
  List<bool> modeToggle = [true, false];
  final LESSON_COURSES = 'LessonCourses';
  final ORDER_ID = 'orderId';
  final IS_BEGINNER_MODE = 'isBeginnerMode';
  late List<LessonCourse> courses;
  String setLanguage = 'en'; //todo: 기기 설정에 따라 바뀌게 하기

  Widget getListItem({required LessonCourse lessonCourse}) {
    String sampleImage = 'assets/images/course_hangul.png';
    return Card(
      child: InkWell(
        onTap: () {
          Get.to(const LessonMain(), arguments: lessonCourse);
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
                      tag: 'courseImage:${lessonCourse.id}',
                      child: Image.asset(sampleImage),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: MyWidget().getTextWidget(
                      text: lessonCourse.title[setLanguage],
                      size: 25,
                      color: MyColors.purple,
                      isBold: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: modeToggle[0] ? 20 : 0),
              modeToggle[0]
                  ? MyWidget().getTextWidget(
                      text: lessonCourse.description[setLanguage],
                      size: 15,
                      color: MyColors.grey,
                    )
                  : const SizedBox.shrink(),
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
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyWidget().getTextWidget(
                    text: MyStrings.selectCourse,
                    size: 20,
                    color: MyColors.purple,
                    isBold: true,
                  ),
                  ToggleButtons(
                    isSelected: modeToggle,
                    onPressed: (int index) {
                      setState(() {
                        modeToggle[0] = 0 == index;
                        modeToggle[1] = 1 == index;
                      });
                    },
                    constraints: const BoxConstraints(minHeight: 35, minWidth: 45),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    selectedBorderColor: MyColors.purple,
                    selectedColor: Colors.white,
                    fillColor: MyColors.purple,
                    color: MyColors.purple,
                    children: const [
                      Text(MyStrings.beg),
                      Text(MyStrings.int),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: FutureBuilder(
                  future: Database().getDocsFromDb(
                      collection: LESSON_COURSES,
                      field: IS_BEGINNER_MODE,
                      equalTo: modeToggle[0],
                      orderBy: ORDER_ID,
                      descending: false),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                      courses = [];
                      for (dynamic snapshot in snapshot.data) {
                        courses.add(LessonCourse.fromJson(snapshot));
                      }
                      if (courses.isEmpty) {
                        return const Center(
                            child: Text(MyStrings.courseError, style: TextStyle(color: MyColors.purple)));
                      } else {
                        return ListView.builder(
                          itemCount: courses.length,
                          itemBuilder: (BuildContext context, int index) {
                            LessonCourse course = courses[index];
                            return getListItem(lessonCourse: course);
                          },
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Text('에러: ${snapshot.error}');
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
