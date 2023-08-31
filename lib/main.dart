import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:podo/screens/flashcard/flashcard_edit.dart';
import 'package:podo/screens/flashcard/flashcard_review.dart';
import 'package:podo/screens/lesson/lesson_complete.dart';
import 'package:podo/screens/lesson/lesson_frame.dart';
import 'package:podo/screens/lesson/lesson_summary_main.dart';
import 'package:podo/screens/login/login.dart';
import 'package:podo/screens/login/logo.dart';
import 'package:podo/screens/main_frame.dart';
import 'package:podo/screens/message/podo_message_main.dart';
import 'package:podo/screens/my_page/premium_main.dart';
import 'package:podo/screens/reading/reading_frame.dart';
import 'package:podo/screens/writing/writing_list.dart';
import 'package:podo/screens/writing/writing_main.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: $message");
  await Firebase.initializeApp();
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
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(EasyLocalization(
    supportedLocales: const [
      Locale('en'),
      Locale('es'),
      Locale('fr'),
      Locale('de'),
      Locale('pt'),
      Locale('in'),
      Locale('ru'),
    ],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    child: MyApp())
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    return GetMaterialApp(
      title: 'Podo Korean app',
      theme: ThemeData(primaryColor: MyColors.purple),
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      home: Logo(),
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
        GetPage(name: MyStrings.routePodoMessageMain, page: () => PodoMessageMain()),
      ],
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
