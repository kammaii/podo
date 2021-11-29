import 'package:flutter/material.dart';
import 'package:podo/screens/main_frame.dart';
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
      home: const MainFrame()
    );
  }
}
