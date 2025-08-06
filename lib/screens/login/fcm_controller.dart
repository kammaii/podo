import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/screens/korean_bite/korean_bite.dart';
import 'package:podo/screens/lesson/lesson_controller.dart';
import 'package:podo/screens/message/podo_message.dart';
import 'package:podo/screens/message/podo_message_controller.dart';
import 'package:podo/screens/my_page/user.dart' as user;
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class FcmController extends GetxController {
  bool hasPodoMsg = false;
  Set<String> displayedMsg = {};
  static Map<String,String>? pendingFcmData;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void onInit() {
    super.onInit();
    setupInteractedMessage();
    setForegroundNotificationForIos();
    setForegroundNotificationForAndroid();
    FirebaseInAppMessaging.instance;
  }

  // 백그라운드 상태 시
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from a terminated state.
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    // If the message also contains a data property with a "type" of "chat", navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      String type = message.data['tag'];
      switch (type) {
        case 'writing':
          pendingFcmData = {};
          pendingFcmData!['tag'] = type;
          break;

          //TODO: 이것도 나중에 pendingFCmData에 저장하고 아래 코드들은 main_frame으로 옮길것
        case 'podo_message':
          hasPodoMsg = true;
          await PodoMessage().getPodoMessage();
          final msgController = Get.put(PodoMessageController());
          msgController.setPodoMsgBtn();
          final lessonController = Get.put(LessonController());
          lessonController.update();
          Get.toNamed(MyStrings.routePodoMessageMain);
          break;

        case 'koreanBite':
          pendingFcmData = {};
          pendingFcmData!['tag'] = type;
          pendingFcmData!['koreanBiteId'] = message.data['koreanBiteId'];
          break;
      }
    }
  }
  
  // 포그라운드 상태
  void setForegroundNotificationForIos() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
  }

  void setForegroundNotificationForAndroid() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!: ${message.data['tag']}');
      print('MSG ID: ${message.messageId}');
      print('1: $displayedMsg');
      if (message.notification != null && !displayedMsg.contains(message.messageId)) {
        PlayAudio().playAlarm();
        displayedMsg.add(message.messageId!);
        print('2: $displayedMsg');
        switch (message.data['tag']) {
          case 'podo_message':
            showSnackBar(tr('podosMsg'), message.notification!.body!);
            await PodoMessage().getPodoMessage();
            final messageController = Get.put(PodoMessageController());
            messageController.setPodoMsgBtn();
            final lessonController = Get.find<LessonController>();
            lessonController.update();
            break;

          case 'writing':
            showSnackBar(message.notification!.title!, message.notification!.body!);
            break;
            
          case 'koreanBite':
            showSnackBar(message.notification!.title!, message.notification!.body!, f: () async {
              String koreanBiteId = message.data['koreanBiteId'];
              await Database().getDoc(collection: 'KoreanBites', docId: koreanBiteId).then((snapshot) async {
                KoreanBite bite = KoreanBite.fromJson(snapshot.data() as Map<String, dynamic>);
                await FirebaseAnalytics.instance
                    .logEvent(name: 'fcm_click_koreanbite', parameters: {'title': bite.title['ko']});
                Get.toNamed(MyStrings.routeKoreanBiteListMain, arguments: bite);
              });
            });
          break;
        }
      }
    });
  }
  
  void showSnackBar(String title, String content, {Function? f}) {
    Get.snackbar(
      title,
      content,
      colorText: MyColors.purple,
      backgroundColor: Colors.white,
      icon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Image.asset('assets/images/podo.png', height: 100, width: 100),
      ),
      duration: Duration(milliseconds: 5000),
      onTap: f != null ? (_) => f() : null,
    );
  }

  Future<bool> fcmRequest(String location) async {
    bool permission;
    NotificationSettings settings = await messaging.requestPermission();
    print('SETTINGS: $settings');
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      permission = true;
      await analytics.logEvent(
          name: 'fcm_permission',
          parameters: {'status': 'true', 'location': location});
    } else {
      permission = false;
      await analytics.logEvent(
          name: 'fcm_permission',
          parameters: {'status': 'false', 'location': location});
    }
    user.User().fcmPermission = permission;
    await Database().updateDoc(collection: 'Users', docId: user.User().id, key: 'fcmPermission', value: permission);
    print('PERMISSION: $permission');
    return permission;
  }

  Future<bool> getFcmRequest() async {
    final settings = await messaging.getNotificationSettings();
    bool permission = settings.authorizationStatus == AuthorizationStatus.authorized;
    print('GET FCM REQUEST: $permission');
    return permission;
  }
}
