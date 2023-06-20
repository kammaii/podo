import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/screens/flashcard/flashcard_edit.dart';
import 'package:podo/screens/flashcard/flashcard_review.dart';
import 'package:podo/screens/lesson/lesson_complete.dart';
import 'package:podo/screens/lesson/lesson_frame.dart';
import 'package:podo/screens/lesson/lesson_summary_main.dart';
import 'package:podo/screens/login/login.dart';
import 'package:podo/screens/main_frame.dart';
import 'package:podo/screens/premium/premium_main.dart';
import 'package:podo/screens/profile/user_info.dart' as user_info;
import 'package:podo/screens/reading/reading_frame.dart';
import 'package:podo/screens/writing/writing_list.dart';
import 'package:podo/screens/writing/writing_main.dart';
import 'package:podo/values/my_colors.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // auth emulator init
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  User? currentUser;

  void runDeepLink(Uri deepLink) async {
    await FirebaseAuth.instance.currentUser!.reload();
    currentUser = FirebaseAuth.instance.currentUser;
    Uri uri = Uri.parse(deepLink.toString());
    String mode = uri.queryParameters['mode']!;

    if (mode == 'verifyEmail' && currentUser!.emailVerified) {
      await user_info.User().initNewUserOnDB();
      Get.to(const MainFrame());
    }
  }

  void initDynamicLinks() async {
    // DynamicLink listener : When the app is already running.
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final deepLink = dynamicLinkData.link;
      if (deepLink != null) {
        runDeepLink(deepLink);
      }
    }).onError((error) {
      print('ERROR on DynamicLinkListener: $error');
    });

    // Get any initial links : When the app is just opened by clicking the deepLink.
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    final deepLink = data?.link;
    if (deepLink != null) {
      runDeepLink(deepLink);
    }
  }

  @override
  Widget build(BuildContext context) {

    initDynamicLinks();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if(user != null) {
        if(user.emailVerified) {
          print('AUTH STATE CHANGES: Email Verified');
          user_info.User();
          Get.toNamed('/');
        } else {
          print('AUTH STATE CHANGES: Email not Verified');
          Get.toNamed('/login');
        }
      } else {
        print('AUTH STATE CHANGES: User is null');
        Get.toNamed('/login');
      }
    });

    return GetMaterialApp(
      title: 'Podo Korean app',
      theme: ThemeData(primaryColor: MyColors.purple),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const MainFrame()),
        GetPage(name: '/login', page: () => Login()),
        GetPage(name: '/lessonSummaryMain', page: () => LessonSummaryMain()),
        GetPage(name: '/lessonFrame', page: () => LessonFrame()),
        GetPage(name: '/lessonComplete', page: () => const LessonComplete()),
        GetPage(name: '/writingMain', page: () => WritingMain()),
        GetPage(name: '/myWritingList', page: () => WritingList(true)),
        GetPage(name: '/otherWritingList', page: () => WritingList(false)),
        GetPage(name: '/readingFrame', page: () => const ReadingFrame()),
        GetPage(name: '/flashcardEdit', page: () => FlashCardEdit()),
        GetPage(name: '/flashcardReview', page: () => const FlashCardReview()),
        GetPage(name: '/premiumMain', page: () => PremiumMain()),
      ],
    );
  }
}
