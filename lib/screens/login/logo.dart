import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/fcm_controller.dart';
import 'package:podo/screens/lesson/lesson_controller.dart';
import 'package:podo/screens/lesson/lesson_course_controller.dart';
import 'package:podo/screens/message/podo_message.dart';
import 'package:podo/screens/message/podo_message_controller.dart';
import 'package:podo/screens/my_page/my_page_controller.dart';
import 'package:podo/screens/reading/reading_controller.dart';
import 'package:podo/screens/writing/writing_controller.dart';
import 'package:podo/values/my_strings.dart';
import 'package:podo/screens/my_page/user.dart' as user;

class Logo extends StatelessWidget {
  Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ResponsiveSize rs = ResponsiveSize(context);

    getInitData() async {
      await user.User().getUser();
      await LocalStorage().getPrefs();
      final myPageController = Get.find<MyPageController>();
      myPageController.loadThemeMode();
      final courseController = Get.put(LessonCourseController());
      await courseController.loadCourses();
      await PodoMessage().getPodoMessage();
      Get.put(WritingController());
      Get.put(ReadingController());
      Get.toNamed(MyStrings.routeMainFrame);
      if (user.User().os.isEmpty) {
        String os = '';
        if (Platform.isIOS) {
          os = 'iOS';
        } else if (Platform.isAndroid) {
          os = 'android';
        } else if (Platform.isWindows) {
          os = 'windows';
        } else if (Platform.isMacOS) {
          os = 'macOS';
        } else if (Platform.isLinux) {
          os = 'linux';
        } else {
          os = 'others';
        }
        Database().updateDoc(collection: 'Users', docId: user.User().id, key: 'os', value: os);
      }
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      bool permission = settings.authorizationStatus == AuthorizationStatus.authorized;
      if (user.User().fcmPermission != permission) {
        Database().updateDoc(collection: 'Users', docId: user.User().id, key: 'fcmPermission', value: permission);
      }
      print('STATUS: ${user.User().status}');
    }

    void runDeepLink(Uri deepLink) async {
      print('RUN DEEPLINK: $deepLink');
      Uri uri = Uri.parse(deepLink.toString());
      String mode = uri.queryParameters['mode']!;
      await FirebaseAuth.instance.currentUser!.reload();
      User? currentUser = FirebaseAuth.instance.currentUser;

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

    initDynamicLinks();

    Get.put(FcmController());

    FirebaseInAppMessaging.instance;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      if (message.notification != null) {
        PlayAudio().playAlarm();
        switch (message.data['tag']) {
          case 'podo_message':
            MyWidget().showSnackbarWithPodo(rs,
                title: tr('podosMsg'),
                content: message.notification!.body!,
                titleSize: rs.getSize(20),
                contentSize: rs.getSize(18));
            await PodoMessage().getPodoMessage();
            final messageController = Get.put(PodoMessageController());
            messageController.setPodoMsgBtn();
            final lessonController = Get.find<LessonController>();
            lessonController.update();
            break;

          case 'writing':
            MyWidget().showSnackbarWithPodo(rs,
                title: message.notification!.title!,
                content: message.notification!.body!,
                titleSize: rs.getSize(20),
                contentSize: rs.getSize(18));
            break;
        }
      }
    });

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      try {
        if (user != null && user.emailVerified) {
          print('AUTH STATE CHANGES: Email Verified');
          getInitData();
        } else {
          print('AUTH STATE CHANGES: User is null or not verified');
          Get.offNamed(MyStrings.routeLogin);
        }
      } catch (e, stackTrace) {
        final fc = FirebaseCrashlytics.instance;
        fc.log('AuthStateChanges Error');
        if (user != null) {
          fc.setCustomKey('user', user);
          fc.setCustomKey('emailVerified', user.emailVerified);
        } else {
          fc.log('User is null');
        }
        fc.recordError(e, stackTrace);
      }
    });

    return Scaffold(
      body: Container(
        color: Theme.of(context).cardColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  int buildNumber = int.parse(snapshot.data.buildNumber);
                  return Positioned(
                      top: rs.getSize(20),
                      right: rs.getSize(20),
                      child: MyWidget().getTextWidget(rs,
                          text: 'version : ${snapshot.data.version}',
                          color: Theme.of(context).secondaryHeaderColor));
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            Center(child: Image.asset('assets/images/logo.png')),
            Positioned(
              bottom: 100.0,
              child: Row(
                children: [
                  SizedBox(
                    height: rs.getSize(20),
                    width: rs.getSize(20),
                    child: CircularProgressIndicator(
                      strokeWidth: rs.getSize(1),
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  MyWidget()
                      .getTextWidget(rs, text: 'Loading...', color: Theme.of(context).secondaryHeaderColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
