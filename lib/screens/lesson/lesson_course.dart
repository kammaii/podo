import 'package:flutter/material.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'lesson_main.dart';

class LessonCourse extends StatefulWidget {
  LessonCourse({Key? key}) : super(key: key);

  @override
  State<LessonCourse> createState() => _LessonCourseState();
}

class _LessonCourseState extends State<LessonCourse> {
  List<bool> modeToggle = [true, false];
  final LESSON_COURSES = 'LessonCourses';
  final ORDER_ID = 'orderId';
  late Future<List<dynamic>> futureList;

  Widget getListItem(BuildContext context, int key, String title) {
    String sampleImage = 'assets/images/course_hangul.png';
    return Card(
      key: ValueKey(key),
      child: InkWell(
        onTap: () {
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
                      tag: 'courseImage:$title',
                      child: Image.asset(sampleImage),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: MyWidget().getTextWidget(
                      text: title,
                      size: 25,
                      color: MyColors.purple,
                      isBold: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              MyWidget().getTextWidget(
                text: MyStrings.lorem,
                size: 15,
                color: MyColors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  getCourses() {
    futureList = Database().getDocsFromDb(collection: LESSON_COURSES, orderBy: ORDER_ID);
  }

  @override
  void initState() {
    super.initState();
    getCourses();
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
                child: ListView(
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
      ),
    );
  }
}
