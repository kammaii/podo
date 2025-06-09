import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:podo/common/ads_controller.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/fcm_request.dart';
import 'package:podo/common/languages.dart';
import 'package:podo/common/my_remote_config.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class User {
  User._init();

  static final User _instance = User._init();

  factory User() {
    return _instance;
  }

  late String id;
  late String os;
  late String email;
  late String name;
  late DateTime dateSignUp;
  late DateTime dateSignIn;
  DateTime? trialStart;
  DateTime? trialEnd;
  late String language;
  String? fcmToken;
  late bool fcmPermission;
  late int status;
  int? buildNumber;
  String? expirationDate; // only for MyPage
  bool showPremiumDialog = true;
  bool isConvertedBasic = false;
  bool needUpdate = false;
  String? path;
  bool? isFreeTrialEnabled;
  String discordLink = ''; // discord 초대 링크 만료 문제 해결되면 삭제할 것
  String? timezone;

  static const String ID = 'id';
  static const String OS = 'os';
  static const String EMAIL = 'email';
  static const String NAME = 'name';
  static const String DATESIGNUP = 'dateSignUp';
  static const String DATESIGNIN = 'dateSignIn';
  static const String TRIAL_START = 'trialStart';
  static const String TRIAL_END = 'trialEnd';
  static const String PREMIUM_START = 'premiumStart';
  static const String PREMIUM_END = 'premiumEnd';
  static const String PREMIUM_LATEST_PURCHASE = 'premiumLatestPurchase';
  static const String PREMIUM_UNSUBSCRIBE_DETECTED = 'premiumUnsubscribeDetected';
  static const String PREMIUM_WILL_RENEW = 'premiumWillRenew';
  static const String LANGUAGE = 'language';
  static const String FCM_TOKEN = 'fcmToken';
  static const String FCM_PERMISSION = 'fcmPermission';
  static const String STATUS = 'status';
  static const String BUILD_NUMBER = 'buildNumber';
  static const String ALL_USERS = 'allUsers';
  static const String NEW_USERS = 'newUsers';
  static const String BASIC_USERS = 'basicUsers';
  static const String PREMIUM_USERS = 'premiumUsers';
  static const String PREMIUM_EXPIRED_USERS = 'premiumExpiredUsers';
  static const String TRIAL_USERS = 'trialUsers';
  static const String TRIAL_EXPIRED_USERS = 'trialExpiredUsers';
  static const String PATH = 'path';
  static const String IS_FREE_TRIAL_ENABLED = 'isFreeTrialEnabled';
  static const String TIMEZONE = 'timezone';

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      OS: os,
      EMAIL: email,
      NAME: name,
      DATESIGNUP: dateSignUp,
      DATESIGNIN: dateSignIn,
      LANGUAGE: language,
      FCM_PERMISSION: fcmPermission,
      STATUS: status,
      BUILD_NUMBER: buildNumber,
    };
    if (fcmToken != null) {
      map[FCM_TOKEN] = fcmToken;
    }
    if (trialStart != null) {
      map[TRIAL_START] = trialStart;
    }
    if (trialEnd != null) {
      map[TRIAL_END] = trialEnd;
    }
    if (path != null) {
      map[PATH] = path;
    }
    if(isFreeTrialEnabled != null) {
      map[IS_FREE_TRIAL_ENABLED] = isFreeTrialEnabled;
    }

    return map;
  }

  Future<void> getUser() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }
    id = auth.FirebaseAuth.instance.currentUser!.uid;
    FirebaseCrashlytics.instance.setUserIdentifier(id);
    DocumentSnapshot<Map<String, dynamic>>? snapshot = await Database().getDoc(collection: 'Users', docId: id);
    if(snapshot == null) {
      await FirebaseAnalytics.instance.logEvent(name: 'connection_issue', parameters: {'userId': id});
      await Get.dialog(
          AlertDialog(
            title: Text(tr('oops')),
            content: Text(tr('connection_issue')),
            actions: [
              ElevatedButton(onPressed: () async {
                Get.back();
                getUser();
              }, child: Text('try_again'))
            ],
          )
      );
      return;
    }
    if (snapshot.exists) {
      final json = snapshot.data()!;
      id = json[ID];
      os = json[OS];
      email = json[EMAIL];
      name = json[NAME];
      Timestamp stamp = json[DATESIGNUP];
      dateSignUp = stamp.toDate();
      dateSignIn = DateTime.now();
      FirebaseFirestore.instance
          .collection('Users')
          .doc(id)
          .update({'dateSignIn': DateTime.now(), 'dateEmailSend': FieldValue.delete()});
      language = json[LANGUAGE];
      if (json[FCM_TOKEN] != null) {
        fcmToken = json[FCM_TOKEN];
      }
      fcmPermission = json[FCM_PERMISSION] ?? false;
      bool p = await FcmRequest().getFcmRequest();

      if(fcmPermission != p) {
        fcmPermission = p;
        await Database().updateDoc(collection: 'Users', docId: id, key: 'fcmPermission', value: fcmPermission);
      }

      if (json[TRIAL_START] != null) {
        Timestamp stamp = json[TRIAL_START];
        trialStart = stamp.toDate();
      }
      if (json[TRIAL_END] != null) {
        Timestamp stamp = json[TRIAL_END];
        trialEnd = stamp.toDate();
      }
      status = json[STATUS];
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      messaging.subscribeToTopic(ALL_USERS);

      if (status == 3 && DateTime.now().isAfter(trialEnd!)) {
        messaging.unsubscribeFromTopic(TRIAL_USERS);
        status = 1;
        isConvertedBasic = true;
      }
      await initRevenueCat();

      try {
        CustomerInfo customerInfo = await Purchases.getCustomerInfo();
        final premiumEntitlement = customerInfo.entitlements.active['premium'];
        if (premiumEntitlement != null) {
          String premiumEnd = premiumEntitlement.expirationDate ?? 'Lifetime';
          expirationDate = premiumEnd.substring(0, 10).replaceAll('-', '.');
          messaging.subscribeToTopic(PREMIUM_USERS);
          messaging.unsubscribeFromTopic(NEW_USERS);
          messaging.unsubscribeFromTopic(BASIC_USERS);
          messaging.unsubscribeFromTopic(TRIAL_USERS);
          messaging.unsubscribeFromTopic(PREMIUM_EXPIRED_USERS);
          messaging.unsubscribeFromTopic(TRIAL_EXPIRED_USERS);
          status = 2;
        } else {
          if (status == 2) {
            messaging.subscribeToTopic(PREMIUM_EXPIRED_USERS);
            messaging.unsubscribeFromTopic(PREMIUM_USERS);
            status = 1;
          }

          if(status == 0) {
            messaging.subscribeToTopic(NEW_USERS);
            Get.put(AdsController());
          }

          if(status == 1) {
            messaging.subscribeToTopic(BASIC_USERS);
            Get.put(AdsController());
          }
        }
      } on PlatformException catch (e) {
        print('CustomerInfo Error: $e');
      }
      if (json[STATUS] != status) {
        Database().updateDoc(collection: 'Users', docId: id, key: 'status', value: status);
      }
      buildNumber = json[BUILD_NUMBER];
      fcmToken = await messaging.getToken();

      if (json[FCM_TOKEN] != fcmToken) {
        Database().updateDoc(collection: 'Users', docId: id, key: 'fcmToken', value: fcmToken);
      }

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      int buildNum = int.parse(packageInfo.buildNumber);
      if (buildNumber == null || buildNumber != buildNum) {
        buildNumber = buildNum;
        Database().updateDoc(collection: 'Users', docId: id, key: 'buildNumber', value: buildNumber);
      }

      DocumentSnapshot<Map<String, dynamic>> buildNumSnapshot = await Database().getDoc(collection: 'BuildNumber', docId: 'latest');
      if(buildNumSnapshot.exists) {
        int lastBuildNum = buildNumSnapshot.data()!['buildNumber'];
        discordLink = buildNumSnapshot.data()!['discordLink'];
        if(lastBuildNum > buildNumber!) {
          needUpdate = true;
        }
      }

      if(json[IS_FREE_TRIAL_ENABLED] != null) {
        isFreeTrialEnabled = json[IS_FREE_TRIAL_ENABLED];
      }

      setAnalyticsUserProp();

      final String timeZone = await FlutterTimezone.getLocalTimezone();
      print('타임존: $timeZone');
      Database().updateDoc(collection: 'Users', docId: id, key: TIMEZONE, value: timeZone);


    } else {
      print('신규유저입니다. DB를 생성합니다.');
      await makeNewUserOnDB();
    }
  }

  Future<void> setAnalyticsUserProp() async {
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    await analytics.setUserId(id: id);
    await analytics.setUserProperty(name: 'status', value: status.toString());
  }

  Future<void> initRevenueCat() async {
    kReleaseMode ? await Purchases.setLogLevel(LogLevel.info) : await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration('goog_IrgDnSOPACytiiXbUDBsujekFpq');
    } else {
      configuration = PurchasesConfiguration('appl_hEvHiLFZOlJwFZxscsqtYyYfTyO');
    }
    await Purchases.configure(configuration..appUserID = id);
  }

  sendWelcomeEmail() async {
    final response = await http.post(
      Uri.parse('https://us-central1-podo-49335.cloudfunctions.net/onSendWelcomeEmail'),
      body: {
        'email': email,
        'userId': id,
        'appInstalledOn': dateSignUp.toIso8601String(),
      },
    );

    if (response.statusCode == 200) {
      print('환영 이메일 전송 성공');
    } else {
      print('환영 이메일 전송 실패: ${response.statusCode}');
      print(response.body);
    }
  }

  Future<void> makeNewUserOnDB() async {
    auth.User user = auth.FirebaseAuth.instance.currentUser!;
    id = user.uid;
    os = '';
    email = user.email ?? '';
    name = user.displayName ?? '';
    dateSignUp = DateTime.now();
    dateSignIn = DateTime.now();
    Locale locale = window.locale;
    language = locale.languageCode;
    if (!Languages().fos.contains(language)) {
      language = 'en';
    }
    status = 0;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    buildNumber = int.parse(packageInfo.buildNumber);
    final prefs = await SharedPreferences.getInstance();
    String? p = prefs.getString('path');
    if(p != null) {
      path = p;
    }
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    fcmToken = await messaging.getToken();
    fcmPermission = false;
    isFreeTrialEnabled = MyRemoteConfig().getConfigBool(MyRemoteConfig.IS_FREE_TRIAL_ENABLED);
    timezone = await FlutterTimezone.getLocalTimezone();

    setAnalyticsUserProp();

    await Database().setDoc(collection: 'Users', doc: this);
    await FcmRequest().fcmRequest('signUp');

    Get.put(AdsController());
    await initRevenueCat();

    sendWelcomeEmail();
  }

  Future<void> setTrialAuthorized() async {
    FirebaseMessaging.instance.subscribeToTopic(TRIAL_USERS);
    status = 3;
    DateTime now = DateTime.now();
    trialStart = now;
    trialEnd = now.add(const Duration(days: 7));
    Map<String, dynamic> map = {
      STATUS: status,
      TRIAL_START: trialStart,
      TRIAL_END: trialEnd,
    };
    await Database().updateFields(collection: 'Users', docId: id, fields: map);
  }
}
