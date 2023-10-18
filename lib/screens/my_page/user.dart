import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:podo/common/ads_controller.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/languages.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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
  List<String>? fcmTopic;
  late bool fcmPermission;
  late int status;
  String? expirationDate; // only for MyPage
  final admin = 'gabmanpark@gmail.com';

  static const String ID = 'id';
  static const String OS = 'os';
  static const String EMAIL = 'email';
  static const String NAME = 'name';
  static const String DATESIGNUP = 'dateSignUp';
  static const String DATESIGNIN = 'dateSignIn';
  static const String TRIAL_START = 'trialStart';
  static const String TRIAL_END = 'trialEnd';
  static const String LANGUAGE = 'language';
  static const String FCM_TOKEN = 'fcmToken';
  static const String FCM_TOPIC = 'fcmTopic';
  static const String FCM_PERMISSION = 'fcmPermission';
  static const String STATUS = 'status';
  static const String ALL_USERS = 'allUsers';

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      OS: os,
      EMAIL: email,
      NAME: name,
      DATESIGNUP: dateSignUp,
      DATESIGNIN: dateSignIn,
      LANGUAGE: language,
      FCM_TOPIC: fcmTopic,
      FCM_PERMISSION: fcmPermission,
      STATUS: status,
    };
    if(fcmToken != null) {
      map[FCM_TOKEN] = fcmToken;
    }
    if(trialStart != null) {
      map[TRIAL_START] = trialStart;
    }
    if(trialEnd != null) {
      map[TRIAL_END] = trialEnd;
    }
    return map;
  }

  Future<void> getUser() async {
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
      Database().updateDoc(collection: 'Users', docId: id, key: 'dateSignIn', value: DateTime.now());
      language = json[LANGUAGE];
      if(json[FCM_TOKEN] != null) {
        fcmToken = json[FCM_TOKEN];
      }
      FirebaseMessaging.instance.subscribeToTopic(ALL_USERS);
      if(json[FCM_TOPIC] != null) {
        fcmTopic = json[FCM_TOPIC];
      }
      fcmPermission = json[FCM_PERMISSION] ?? false;
      if(json[TRIAL_START] != null) {
        Timestamp stamp = json[TRIAL_START];
        trialStart = stamp.toDate();
      }
      if(json[TRIAL_END] != null) {
        Timestamp stamp = json[TRIAL_END];
        trialEnd = stamp.toDate();
      }
      status = json[STATUS];

      if(status == 3 && DateTime.now().isAfter(trialEnd!)) {
        status = 1;
      }

      if(status != 0) {
        await initRevenueCat();
      }

      if(status == 1 || status == 2) {
        try {
          CustomerInfo customerInfo = await Purchases.getCustomerInfo();
          final entitlement = customerInfo.entitlements.active;
          if(entitlement['premium'] != null) {
            expirationDate = entitlement['premium']!.expirationDate.toString().substring(0, 10).replaceAll('-', '.');
          }
          if (entitlement.isNotEmpty) {
            status = 2;
          } else {
            status = 1;
            Get.put(AdsController());
          }
        } on PlatformException catch (e) {
          print('CustomerInfo Error: $e');
        }
      }

      if (json[STATUS] != status) {
        Database().updateDoc(collection: 'Users', docId: id, key: 'status', value: status);
      }

      final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
      await analytics.setUserId(id: id);
      await analytics.setUserProperty(name: 'status', value: status.toString());

    } else {
      print('신규유저입니다. DB를 생성합니다.');
      makeNewUserOnDB();
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
    if(!Languages().fos.contains(language)) {
      language = 'en';
    }
    fcmPermission = false;
    status = 0;
    Database().setDoc(collection: 'Users', doc: this);
    
    List<String> signInMethods = await auth.FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    if(signInMethods.isNotEmpty) {
      String method = 'email';
      for(String signInMethod in signInMethods) {
        if(signInMethod == 'google.com') {
          method = 'google';
        } else if(signInMethod == 'apple.com') {
          method = 'apple';
        }
      }
      print('SIgn up method : $method');
      await FirebaseAnalytics.instance.logSignUp(signUpMethod: method);
    }
  }

  Future<void> setTrialAuthorized(ResponsiveSize rs, bool permission) async {
    status = 3;
    fcmPermission = permission;
    DateTime now = DateTime.now();
    trialStart = now;
    trialEnd = now.add(const Duration(days: 10));
    if(permission) {
      fcmToken = await FirebaseMessaging.instance.getToken();
    }
    await Database().setDoc(collection: 'Users', doc: this);
  }
}
