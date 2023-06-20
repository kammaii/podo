import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/languages.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/premium/premium.dart';
import 'package:podo/values/my_strings.dart';
import 'package:podo/common/database.dart';

class User {
  static final User _instance = User.init();

  factory User() {
    return _instance;
  }

  late String id;
  late String email;
  late String name;
  late String language;
  late List<Premium>? premiumRecord;
  late Map<String, dynamic> lessonRecord;
  late Map<String, dynamic> readingRecord;
  String? fcmToken;
  String? fcmState;
  late int status;

  User.init() {
    debugPrint('User init');
    getUser();
  }

  static const String ID = 'id';
  static const String EMAIL = 'email';
  static const String NAME = 'name';
  static const String LANGUAGE = 'language';
  static const String PREMIUM_RECORD = 'premiumRecord';
  static const String LESSON_RECORD = 'lessonRecord';
  static const String READING_RECORD = 'readingRecord';
  static const String FCM_TOKEN = 'fcmToken';
  static const String FCM_STATE = 'fcmState';
  static const String STATUS = 'status';

  User.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    email = json[EMAIL];
    name = json[NAME];
    language = json[LANGUAGE];
    premiumRecord = json[PREMIUM_RECORD];
    lessonRecord = json[LESSON_RECORD];
    readingRecord = json[READING_RECORD];
    if(json[FCM_TOKEN] != null) {
      fcmToken = json[FCM_TOKEN];
    }
    if(json[FCM_STATE] != null) {
      fcmState = json[FCM_STATE];
    }
    status = json[STATUS];
    print('HERE: $status');

  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      EMAIL: email,
      NAME: name,
      LANGUAGE: language,
      LESSON_RECORD: lessonRecord,
      READING_RECORD: readingRecord,
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

  Future<void> initNewUserOnDB() async {
    auth.User user = auth.FirebaseAuth.instance.currentUser!;
    id = user.uid;
    email = user.email ?? '';
    name = user.displayName ?? '';
    Locale locale = window.locale;
    language = locale.languageCode;
    if(!Languages().fos.contains(language)) {
      language = 'en';
    }
    premiumRecord = [];
    lessonRecord = {};
    readingRecord = {};
    status = 0;
    Database().setDoc(collection: 'Users', doc: this);
  }


  void getUser() async {
    id = auth.FirebaseAuth.instance.currentUser!.uid!;
    DocumentSnapshot<Map<String, dynamic>> snapshot = await Database().getDoc(collection: 'Users', docId: id);
    if (snapshot.exists) {
      User.fromJson(snapshot.data()!);
      print('STATE: $status');
    } else {
      Get.dialog(AlertDialog(
        title: MyWidget().getTextWidget(text: MyStrings.failedUserTitle),
        content: MyWidget().getTextWidget(text: MyStrings.failedUserContent),
      ));
    }
  }

}
