import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:podo/fcm_controller.dart';
import 'package:podo/screens/lesson/lesson_course_controller.dart';
import 'package:podo/screens/message/podo_message.dart';
import 'package:podo/screens/writing/writing_controller.dart';
import 'package:podo/values/my_strings.dart';
import 'package:podo/screens/my_page/user.dart' as user;
import 'login.dart';

class Logo extends StatelessWidget {
  Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TargetPlatform os = Theme.of(context).platform;

    getInitData() async {
      await user.User().getUser();
      FirebaseMessaging.instance.subscribeToTopic('allUsers');
      await LocalStorage().getPrefs();
      final courseController = Get.put(LessonCourseController());
      await courseController.loadCourses();
      await PodoMessage().getPodoMessage();
      Get.put(WritingController());
      Get.toNamed(MyStrings.routeMainFrame);
      String thisOs = os.toString().split('.').last;
      if (thisOs != user.User().os) {
        Database().updateDoc(collection: 'Users', docId: user.User().id, key: 'os', value: thisOs);
      }
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      bool permission = settings.authorizationStatus == AuthorizationStatus.authorized;
      if (user.User().fcmPermission != permission) {
        Database().updateDoc(collection: 'Users', docId: user.User().id, key: 'fcmPermission', value: permission);
      }
    }

    void runDeepLink(Uri deepLink) async {
      print('RUN DEEPLINK');
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

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      if (message.notification != null) {
        PlayAudio().playAlarm();
        switch (message.data['tag']) {
          case 'podo_message' :
            MyWidget().showSnackbarWithPodo(
              title: tr('podosMsg'),
              content: message.notification!.body!,
            );
            break;

          case 'writing' :
            MyWidget().showSnackbarWithPodo(
              title: message.notification!.title!,
              content: message.notification!.body!,
            );
            break;
        }
      }
    });

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && user.emailVerified) {
        print('AUTH STATE CHANGES: Email Verified');
        getInitData();
      } else {
        print('AUTH STATE CHANGES: User is null or not verified');
        Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Stack(
            alignment: Alignment.center,
            children: [
              FutureBuilder(
                future: PackageInfo.fromPlatform(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if(snapshot.hasData) {
                    return Positioned(top: 20.0, right: 20.0, child: Text('version : ${snapshot.data.version}'));
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              Center(child: Image.asset('assets/images/logo.png')),
              const Positioned(
                bottom: 100.0,
                child: Row(
                  children: [
                    SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.0,
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Text('Loading...')
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
