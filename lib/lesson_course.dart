import 'package:flutter/material.dart';
import 'package:podo/my_colors.dart';

class LessonCourse extends StatefulWidget {
  const LessonCourse({Key? key}) : super(key: key);

  @override
  _LessonCourseState createState() => _LessonCourseState();
}

Widget getListItem(int key) {
  return Container(
    key: ValueKey(key),
    padding: const EdgeInsets.symmetric(vertical: 5),
    height: 200,
    child: Card(
      child: InkWell(
        onTap: () {
          print(key);
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset('assets/images/course_hangul.png')),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Text(
                      'Hangul',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: MyColors.navy
                      ),
                    )
                  )
                ],
              ),
              const SizedBox(height: 20),
              const Expanded(
                  child: Text(
                    'This lesson is ...',
                    style: TextStyle(
                      color: MyColors.grey,
                      fontSize: 15
                    ),
              ))
            ],
          ),
        ),
      ),
    ),
  );
}

class _LessonCourseState extends State<LessonCourse> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select lesson course'),
        backgroundColor: MyColors.primaryPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          getListItem(0),
          getListItem(1),
          getListItem(2),
          getListItem(3)
        ],
      ),
    );
  }
}
