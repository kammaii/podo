import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/ads_controller.dart';
import 'package:podo/common/languages.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/premium/premium.dart';
import 'package:podo/values/my_strings.dart';
import 'package:podo/common/database.dart';

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
  late String language;
  late List<Premium>? premiumRecord;
  String? fcmToken;
  String? fcmState;
  late int status;

  static const String ID = 'id';
  static const String OS = 'os';
  static const String EMAIL = 'email';
  static const String NAME = 'name';
  static const String DATESIGNUP = 'dateSignUp';
  static const String DATESIGNIN = 'dateSignIn';
  static const String LANGUAGE = 'language';
  static const String PREMIUM_RECORD = 'premiumRecord';
  static const String FCM_TOKEN = 'fcmToken';
  static const String FCM_STATE = 'fcmState';
  static const String STATUS = 'status';

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      OS: os,
      EMAIL: email,
      NAME: name,
      DATESIGNUP: dateSignUp,
      DATESIGNIN: dateSignIn,
      LANGUAGE: language,
      STATUS: status,
    };
    if(fcmToken != null) {
      map[FCM_TOKEN] = fcmToken;
    }
    if(fcmState != null) {
      map[FCM_STATE] = fcmState;
    }
    return map;
  }

  Future<void> makeNewUserOnDB(TargetPlatform platform) async {
    auth.User user = auth.FirebaseAuth.instance.currentUser!;
    id = user.uid;
    os = platform.toString().split('.').last;
    email = user.email ?? '';
    name = user.displayName ?? '';
    dateSignUp = DateTime.now();
    dateSignIn = DateTime.now();
    Locale locale = window.locale;
    language = locale.languageCode;
    if(!Languages().fos.contains(language)) {
      language = 'en';
    }
    premiumRecord = [];
    status = 0;
    Database().setDoc(collection: 'Users', doc: this);
  }


  Future<void> getUser() async {
    id = auth.FirebaseAuth.instance.currentUser!.uid;
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
      premiumRecord = json[PREMIUM_RECORD];
      if(json[FCM_TOKEN] != null) {
        fcmToken = json[FCM_TOKEN];
      }
      if(json[FCM_STATE] != null) {
        fcmState = json[FCM_STATE];
      }
      status = json[STATUS];
      if(status == 1) {
        Get.put(AdsController());
      }

    } else {
      Get.dialog(AlertDialog(
        title: MyWidget().getTextWidget(text: MyStrings.failedUserTitle),
        content: MyWidget().getTextWidget(text: MyStrings.failedUserContent),
      ));
    }
  }
}
