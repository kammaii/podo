import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:podo/common/database.dart';
import 'package:podo/screens/my_page/user.dart';

class FcmRequest {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

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
    User().fcmPermission = permission;
    await Database().updateDoc(collection: 'Users', docId: User().id, key: 'fcmPermission', value: permission);
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
