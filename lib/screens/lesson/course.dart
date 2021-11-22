import 'package:flutter/material.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class LessonCourse extends StatelessWidget {
  const LessonCourse({Key? key}) : super(key: key);

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
                      MyStrings.hangul,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: MyColors.purple,
                      ),
                    ))
                  ],
                ),
                const SizedBox(height: 20),
                const Expanded(
                    child: Text(
                  MyStrings.lorem,
                  style: TextStyle(
                    color: MyColors.grey,
                    fontSize: 15,
                  ),
                ))
              ],
            ),
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
            Container(
              color: MyColors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: const [
                  Text(
                    MyStrings.selectCourse,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  getListItem(0),
                  getListItem(1),
                  getListItem(2),
                  getListItem(3)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
