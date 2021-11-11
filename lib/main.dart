import 'package:flutter/material.dart';
import 'package:podo/login.dart';
import 'package:podo/main_frame.dart';
import 'package:podo/my_colors.dart';
import 'logo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Podo Korean app',
      theme: ThemeData(
        primaryColor: MyColors.primaryPurple
      ),
      home: const MainFrame()
    );
  }
}
