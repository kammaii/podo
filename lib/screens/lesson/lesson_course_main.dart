import 'package:flutter/material.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/items/lesson_course.dart';
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
  late Future<List<dynamic>> futureList;
  late List<LessonCourse> courses;

  Widget getListItem(
      {required BuildContext context, required int key, required String title, required String desc}) {
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
                text: desc,
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
    courses = [];
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
                child: FutureBuilder(
                  future: futureList,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                      courses = [];
                      for (dynamic snapshot in snapshot.data) {
                        courses.add(LessonCourse.fromJson(snapshot));
                      }
                      if (courses.isEmpty) {
                        return const Center(child: Text(MyStrings.courseError));
                      } else {
                        courses.sort((a, b) => a.orderId.compareTo(b.orderId));
                        return ListView.builder(
                          itemCount: courses.length,
                          itemBuilder: (BuildContext context, int index) {
                            LessonCourse course = courses[index];
                            return getListItem(
                                context: context,
                                key: index,
                                title: course.title['en'],
                                desc: course.description['en']);
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
