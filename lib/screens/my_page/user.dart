import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:podo/common/ads_controller.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/languages.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final admin = 'gabmanpark@gmail.com';
  bool isConvertedBasic = false;
  bool needUpdate = false;
  String? path;

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
  static const String PATH = 'path';

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
    return map;
  }

  Future<void> getUser() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }
    id = auth.FirebaseAuth.instance.currentUser!.uid;
    FirebaseCrashlytics.instance.setUserIdentifier(id);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await Database().getDoc(collection: 'Users', docId: id);
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
      FirebaseMessaging.instance.subscribeToTopic(ALL_USERS);
      fcmPermission = json[FCM_PERMISSION] ?? false;
      if (json[TRIAL_START] != null) {
        Timestamp stamp = json[TRIAL_START];
        trialStart = stamp.toDate();
      }
      if (json[TRIAL_END] != null) {
        Timestamp stamp = json[TRIAL_END];
        trialEnd = stamp.toDate();
      }
      status = json[STATUS];

      if (status == 3 && DateTime.now().isAfter(trialEnd!)) {
        FirebaseMessaging.instance.unsubscribeFromTopic('trialUsers');
        status = 1;
      }
      await initRevenueCat();

      try {
        CustomerInfo customerInfo = await Purchases.getCustomerInfo();
        final premiumEntitlement = customerInfo.entitlements.active['premium'];
        if (premiumEntitlement != null) {
          String premiumEnd = premiumEntitlement.expirationDate ?? 'Lifetime';
          expirationDate = premiumEnd.substring(0, 10).replaceAll('-', '.');
          FirebaseMessaging.instance.subscribeToTopic('premiumUsers');
          status = 2;
        } else {
          if (status == 2) {
            FirebaseMessaging.instance.unsubscribeFromTopic('premiumUsers');
            FirebaseMessaging.instance.subscribeToTopic('premiumExpiredUsers');
            status = 1;
          }
          if(status == 3) {
            FirebaseMessaging.instance.subscribeToTopic('trialUsers');
          } else {
            if(status == 0) {
              FirebaseMessaging.instance.subscribeToTopic('newUsers');
            } else {
              FirebaseMessaging.instance.subscribeToTopic('basicUsers');
            }
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
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      if(Platform.isIOS) {
        fcmToken = await messaging.getAPNSToken();
      } else {
        fcmToken = await messaging.getToken();
      }
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
        if(lastBuildNum > buildNumber!) {
          needUpdate = true;
        }
      }

      final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
      await analytics.setUserId(id: id);
      await analytics.setUserProperty(name: 'status', value: status.toString());
    } else {
      print('신규유저입니다. DB를 생성합니다.');
      await makeNewUserOnDB();
    }
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

    List<String> signInMethods = await auth.FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    if (signInMethods.isNotEmpty) {
      String method = 'email';
      for (String signInMethod in signInMethods) {
        if (signInMethod == 'google.com') {
          method = 'google';
          break;
        } else if (signInMethod == 'apple.com') {
          method = 'apple';
          break;
        }
      }
      print('SIgn up method : $method');
      FirebaseAnalytics.instance.logSignUp(signUpMethod: method);
    }
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseAnalytics.instance.logEvent(name: 'fcm_approved');
      fcmPermission = true;
    } else {
      FirebaseAnalytics.instance.logEvent(name: 'fcm_denied');
      fcmPermission = false;
    }
    await Database().setDoc(collection: 'Users', doc: this);

    Get.put(AdsController());
    await initRevenueCat();
  }
}
