import 'package:flutter/material.dart';
import 'package:podo/screens/lesson/lesson_correction.dart';
import 'package:podo/screens/lesson/lesson_finish.dart';
import 'package:podo/values/my_colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Podo Korean app',
      theme: ThemeData(
        primaryColor: MyColors.purple
      ),
      home: const LessonCorrection()
    );
  }
}
