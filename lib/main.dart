import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/screens/favorite/favorite_review.dart';
import 'package:podo/screens/lesson/lesson_finish.dart';
import 'package:podo/screens/lesson/lesson_frame.dart';
import 'package:podo/screens/lesson/lesson_main.dart';
import 'package:podo/screens/lesson/lesson_question.dart';
import 'package:podo/screens/login/login.dart';
import 'package:podo/screens/main_frame.dart';
import 'package:podo/screens/message/message_frame.dart';
import 'package:podo/screens/profile/profile.dart';
import 'package:podo/screens/subscribe/subscribe.dart';
import 'package:podo/values/my_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // auth emulator init
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Podo Korean app',
      theme: ThemeData(
        primaryColor: MyColors.purple
      ),
      home: const Login()
    );
  }
}
