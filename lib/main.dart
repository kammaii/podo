import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/lesson_course_controller.dart';
import 'package:podo/screens/flashcard/flashcard_edit.dart';
import 'package:podo/screens/flashcard/flashcard_review.dart';
import 'package:podo/screens/lesson/lesson_complete.dart';
import 'package:podo/screens/lesson/lesson_frame.dart';
import 'package:podo/screens/lesson/lesson_summary_main.dart';
import 'package:podo/screens/login/login.dart';
import 'package:podo/screens/login/logo.dart';
import 'package:podo/screens/main_frame.dart';
import 'package:podo/screens/premium/premium_main.dart';
import 'package:podo/screens/profile/user.dart' as user;
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

  User? currentUser = FirebaseAuth.instance.currentUser;

  void runDeepLink(Uri deepLink) async {
    Uri uri = Uri.parse(deepLink.toString());
    String mode = uri.queryParameters['mode']!;
    await FirebaseAuth.instance.currentUser!.reload();
    currentUser = FirebaseAuth.instance.currentUser;

    if (mode == 'verifyEmail') {
      if(currentUser != null && currentUser!.emailVerified) {
        await user.User().initNewUserOnDB();
        getInitData(isNewUser: true);
      }
    }
  }

  void initDynamicLinks() async {
    // DynamicLink listener : When the app is already running.
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final deepLink = dynamicLinkData.link;
      runDeepLink(deepLink);
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

  getInitData({bool isNewUser = false}) async {
    if(!isNewUser) {
      await user.User().getUser();
    }
    await LocalStorage().getPrefs();
    final courseController = Get.put(LessonCourseController());
    await courseController.loadCourses();
    Get.offNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    String initialRoute = '/login';
    if (currentUser != null && currentUser!.emailVerified == true) {
      initialRoute = '/logo';
    }

    initDynamicLinks();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        if (user.emailVerified) {
          print('AUTH STATE CHANGES: Email Verified');
          getInitData();
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
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/', page: () => const MainFrame()),
        GetPage(name: '/logo', page: () => Logo()),
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
