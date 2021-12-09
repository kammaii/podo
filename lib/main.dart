import 'package:flutter/material.dart';
import 'package:podo/screens/favorite/favorite_review.dart';
import 'package:podo/screens/lesson/lesson_finish.dart';
import 'package:podo/screens/lesson/lesson_frame.dart';
import 'package:podo/screens/lesson/lesson_question.dart';
import 'package:podo/screens/main_frame.dart';
import 'package:podo/screens/message/message_frame.dart';
import 'package:podo/screens/profile/profile.dart';
import 'package:podo/screens/subscribe/subscribe.dart';
import 'package:podo/values/my_colors.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Podo Korean app',
      theme: ThemeData(
        primaryColor: MyColors.purple
      ),
      home: const Subscribe()
    );
  }
}
