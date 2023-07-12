import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/screens/flashcard/flashcard_edit.dart';
import 'package:podo/screens/flashcard/flashcard_review.dart';
import 'package:podo/screens/lesson/lesson_complete.dart';
import 'package:podo/screens/lesson/lesson_course_controller.dart';
import 'package:podo/screens/lesson/lesson_frame.dart';
import 'package:podo/screens/lesson/lesson_summary_main.dart';
import 'package:podo/screens/login/login.dart';
import 'package:podo/screens/login/logo.dart';
import 'package:podo/screens/main_frame.dart';
import 'package:podo/screens/message/cloud_message.dart';
import 'package:podo/screens/message/cloud_message_main.dart';
import 'package:podo/screens/my_page/user.dart' as user;
import 'package:podo/screens/premium/premium_main.dart';
import 'package:podo/screens/reading/reading_frame.dart';
import 'package:podo/screens/writing/writing_list.dart';
import 'package:podo/screens/writing/writing_main.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

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
  late TargetPlatform os;

  void runDeepLink(Uri deepLink) async {
    print('RUN DEEPLINK');
    Uri uri = Uri.parse(deepLink.toString());
    String mode = uri.queryParameters['mode']!;
    await FirebaseAuth.instance.currentUser!.reload();
    currentUser = FirebaseAuth.instance.currentUser;

    switch (mode) {
      case 'verifyEmail':
        if (currentUser != null && currentUser!.emailVerified) {
          getInitData();
        }
        break;

      case 'cloudMessage':
        break;
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

  getInitData() async {
    await user.User().getUser();
    await LocalStorage().getPrefs();
    final courseController = Get.put(LessonCourseController());
    await courseController.loadCourses();
    await CloudMessage().getCloudMessage();
    Get.toNamed(MyStrings.routeMainFrame);
    String thisOs = os.toString().split('.').last;
    if (thisOs != user.User().os) {
      Database().updateDoc(collection: 'Users', docId: user.User().id, key: 'os', value: thisOs);
    }
  }

  @override
  Widget build(BuildContext context) {
    os = Theme.of(context).platform;
    String initialRoute = '/logo';

    initDynamicLinks();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        if (user.emailVerified) {
          print('AUTH STATE CHANGES: Email Verified');
          getInitData();
        } else {
          print('AUTH STATE CHANGES: Email not Verified');
          Get.offNamedUntil(MyStrings.routeLogin, ModalRoute.withName(MyStrings.routeLogo));
        }
      } else {
        print('AUTH STATE CHANGES: User is null');
        Get.offNamedUntil(MyStrings.routeLogin, ModalRoute.withName(MyStrings.routeLogo));
      }
    });

    return GetMaterialApp(
      title: 'Podo Korean app',
      theme: ThemeData(primaryColor: MyColors.purple),
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/', page: () => MyApp()),
        GetPage(name: MyStrings.routeMainFrame, page: () => const MainFrame()),
        GetPage(name: MyStrings.routeLogo, page: () => Logo()),
        GetPage(name: MyStrings.routeLogin, page: () => Login()),
        GetPage(name: MyStrings.routeLessonSummaryMain, page: () => LessonSummaryMain()),
        GetPage(name: MyStrings.routeLessonFrame, page: () => LessonFrame()),
        GetPage(name: MyStrings.routeLessonComplete, page: () => const LessonComplete()),
        GetPage(name: MyStrings.routeWritingMain, page: () => WritingMain()),
        GetPage(name: MyStrings.routeMyWritingList, page: () => WritingList(true)),
        GetPage(name: MyStrings.routeOtherWritingList, page: () => WritingList(false)),
        GetPage(name: MyStrings.routeReadingFrame, page: () => const ReadingFrame()),
        GetPage(name: MyStrings.routeFlashcardEdit, page: () => FlashCardEdit()),
        GetPage(name: MyStrings.routeFlashcardReview, page: () => const FlashCardReview()),
        GetPage(name: MyStrings.routePremiumMain, page: () => PremiumMain()),
        GetPage(name: MyStrings.routeCloudMessageMain, page: () => CloudMessageMain()),
      ],
    );
  }
}
