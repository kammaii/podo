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
import 'package:podo/common/fcm_request.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_remote_config.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

class Logo extends StatefulWidget {
  Logo({Key? key}) : super(key: key);

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  bool initCalled = false;

  @override
  Widget build(BuildContext context) {
    ResponsiveSize rs = ResponsiveSize(context);

    Future<void> getInitData() async {
      if (initCalled) return;
      initCalled = true;
      MyRemoteConfig();
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
        } else {
          os = 'others';
        }
        Database().updateDoc(collection: 'Users', docId: user.User().id, key: 'os', value: os);
      }
      bool permission = await FcmRequest().getFcmRequest();
      if (user.User().fcmPermission != permission) {
        Database().updateDoc(collection: 'Users', docId: user.User().id, key: 'fcmPermission', value: permission);
        user.User().fcmPermission = permission;
      }
    }

    void runDeepLink(Uri deepLink) async {
      print('RUN DEEPLINK: $deepLink');
      Uri uri = Uri.parse(deepLink.toString());
      String? mode = uri.queryParameters['mode'];
      String? path = uri.queryParameters['path'];
      print('MODE: $mode');
      print('PATH: $path');
      if(path != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('path', path);
      }

      if(mode != null && mode == 'verifyEmail') {
        await FirebaseAuth.instance.currentUser!.reload();
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null && currentUser.emailVerified) {
          getInitData();
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

    initDynamicLinks();

    Get.put(FcmController());

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
                  MyWidget().getTextWidget(rs, text: 'Loading...', color: Theme.of(context).secondaryHeaderColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
