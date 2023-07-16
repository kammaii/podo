import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:podo/values/my_strings.dart';

class FcmController extends GetxController {


  @override
  void onInit() {
    super.onInit();
    setupInteractedMessage();
    //setForegroundNotificationForAndroid();
    setForegroundNotificationForIos();
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

  void _handleMessage(RemoteMessage message) {
    User? user = FirebaseAuth.instance.currentUser;
    print('REMOTE MESSAGE: ${message.notification}');
    if(user != null && user.emailVerified) {
      String type = message.data['type'];
      if (type == 'writing') {
        Get.toNamed(MyStrings.routeWritingMain, arguments: message.data['lessonId']);
      }
    }
  }

  void setForegroundNotificationForIos() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions();
  }

  // void setForegroundNotificationForAndroid() async {
  //   const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //     'high_importance_channel', // id
  //     'High Importance Notifications', // title
  //     'This channel is used for important notifications.', // description
  //     importance: Importance.max,
  //   );
  //
  //   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //
  //   print('PLUGIN: $flutterLocalNotificationsPlugin');
  //
  //   await flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  //       ?.createNotificationChannel(channel);
  //
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     RemoteNotification? notification = message.notification;
  //     AndroidNotification? android = message.notification?.android;
  //
  //     // If `onMessage` is triggered with a notification, construct our own
  //     // local notification to show to users using the created channel.
  //     if (notification != null && android != null) {
  //       flutterLocalNotificationsPlugin.show(
  //           notification.hashCode,
  //           notification.title,
  //           notification.body,
  //           NotificationDetails(
  //               android: AndroidNotificationDetails(
  //                 channel.id,
  //                 channel.name,
  //                 channel.description,
  //                 icon: android?.smallIcon,
  //                 // other properties...
  //               ),
  //               iOS: const IOSNotificationDetails(
  //                 badgeNumber: 1,
  //                 subtitle: 'subTitle',
  //                 sound: 'sound',
  //               )
  //           ));
  //     }
  //   });
  // }
}