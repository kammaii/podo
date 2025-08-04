import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:podo/screens/flashcard/flashcard_edit.dart';
import 'package:podo/screens/flashcard/flashcard_review.dart';
import 'package:podo/screens/korean_bite/korean_bite_frame.dart';
import 'package:podo/screens/korean_bite/korean_bite_list_main.dart';
import 'package:podo/screens/lesson/lesson_complete.dart';
import 'package:podo/screens/lesson/lesson_course_list.dart';
import 'package:podo/screens/lesson/lesson_frame.dart';
import 'package:podo/screens/lesson/lesson_summary_main.dart';
import 'package:podo/screens/lesson/workbook_main.dart';
import 'package:podo/screens/login/login.dart';
import 'package:podo/screens/login/logo.dart';
import 'package:podo/screens/main_frame.dart';
import 'package:podo/screens/message/podo_message_main.dart';
import 'package:podo/screens/my_page/my_page_controller.dart';
import 'package:podo/screens/my_page/premium_main.dart';
import 'package:podo/screens/reading/reading_frame.dart';
import 'package:podo/screens/reading/reading_list_main.dart';
import 'package:podo/screens/writing/writing_main.dart';
import 'package:podo/screens/writing/writing_my_list.dart';
import 'package:podo/screens/writing/writing_other_list.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: $message");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true, printDetails: true);
    return true;
  };
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseAnalytics.instance.setConsent(
    analyticsStorageConsentGranted: true,
    adStorageConsentGranted: true,
    adUserDataConsentGranted: true,
    adPersonalizationSignalsConsentGranted: true,
  );

  runApp(EasyLocalization(supportedLocales: const [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('pt'),
    Locale('id'),
    Locale('ru'),
  ], path: 'assets/translations', fallbackLocale: const Locale('en'), child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    final controller = Get.put(MyPageController());

    return SafeArea(
      child: Obx(() => GetMaterialApp(
            builder: (context, child) => ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
              ],
            ),
            title: 'Podo Korean app',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: false,
              primaryColor: MyColors.purple,
              primaryColorDark: MyColors.navy,
              primaryColorLight: MyColors.navyLight,
              scaffoldBackgroundColor: MyColors.purpleLight,
              cardColor: Colors.white,
              focusColor: MyColors.red,
              shadowColor: MyColors.pink,
              highlightColor: MyColors.navyLight,
              disabledColor: MyColors.grey,
              secondaryHeaderColor: Colors.black,
              unselectedWidgetColor: Colors.black,
              canvasColor: MyColors.purple,
            ),
            darkTheme: ThemeData(
              primaryColor: MyColors.darkWhite,
              primaryColorDark: MyColors.darkWhite,
              primaryColorLight: MyColors.darkBlack,
              scaffoldBackgroundColor: MyColors.darkBlack,
              cardColor: MyColors.darkNavy,
              focusColor: MyColors.darkWhite,
              shadowColor: MyColors.darkPurple,
              highlightColor: MyColors.darkPurple,
              disabledColor: MyColors.darkPurple,
              secondaryHeaderColor: MyColors.darkWhite,
              unselectedWidgetColor: MyColors.darkWhite,
              canvasColor: MyColors.darkPurple,
            ),
            themeMode: controller.themeMode.value,
            navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
            initialRoute: MyStrings.routeLogo,
            getPages: [
              GetPage(name: '/', page: () => Logo()),
              GetPage(name: MyStrings.routeMainFrame, page: () => const MainFrame()),
              GetPage(name: MyStrings.routeLogo, page: () => Logo()),
              GetPage(name: MyStrings.routeLogin, page: () => Login()),
              GetPage(name: MyStrings.routeLessonSummaryMain, page: () => LessonSummaryMain()),
              GetPage(name: MyStrings.routeLessonFrame, page: () => LessonFrame()),
              GetPage(name: MyStrings.routeLessonComplete, page: () => LessonComplete()),
              GetPage(name: MyStrings.routeWritingMain, page: () => WritingMain()),
              GetPage(name: MyStrings.routeMyWritingList, page: () => WritingMyList()),
              GetPage(name: MyStrings.routeOtherWritingList, page: () => WritingOtherList()),
              GetPage(name: MyStrings.routeReadingListMain, page: () => ReadingListMain()),
              GetPage(name: MyStrings.routeReadingFrame, page: () => const ReadingFrame()),
              GetPage(name: MyStrings.routeFlashcardEdit, page: () => FlashCardEdit()),
              GetPage(name: MyStrings.routeFlashcardReview, page: () => const FlashCardReview()),
              GetPage(name: MyStrings.routePremiumMain, page: () => PremiumMain()),
              GetPage(name: MyStrings.routePodoMessageMain, page: () => PodoMessageMain()),
              GetPage(name: MyStrings.routeWorkbookMain, page: () => const WorkbookMain()),
              GetPage(name: MyStrings.routeKoreanBiteListMain, page: () => const KoreanBiteListMain()),
              GetPage(name: MyStrings.routeKoreanBiteFrame, page: () => const KoreanBiteFrame()),
              GetPage(
                  name: MyStrings.routeLessonCourseList,
                  page: () => const LessonCourseList(),
                  transition: Transition.downToUp,
                  transitionDuration: Duration(milliseconds: 300)),
            ],
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
          )),
    );
  }
}
