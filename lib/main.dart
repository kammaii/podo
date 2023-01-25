import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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

  // Get any initial links : When the app is just opened by clicking the deepLink.
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  if (initialLink != null) {
    final Uri deepLink = initialLink.link;
    print(deepLink);
  }

  // auth emulator init
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp(MyApp(link: initialLink));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key, PendingDynamicLinkData? link}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // DynamicLink listener : When the app is already running
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      print('dynamic link listening');
    }).onError((error) {
      // Handle errors
    });

    return GetMaterialApp(
      title: 'Podo Korean app',
      theme: ThemeData(
        primaryColor: MyColors.purple
      ),
      home: const Login()
    );
  }
}
