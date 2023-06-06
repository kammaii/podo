import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/languages.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/profile/premium.dart';
import 'package:podo/values/my_strings.dart';
import 'package:podo/common/database.dart';

class User {
  static final User _instance = User.init();

  factory User() {
    return _instance;
  }

  late String email;
  late String name;
  late String image;
  late String language;
  late bool isBeginnerMode;
  late DateTime dateSignUp;
  late DateTime dateSignIn;
  late List<Premium>? premiumRecord;
  late Map<String, List<String>> lessonRecord;
  late Map<String, List<String>> readingRecord;
  String? fcmToken;
  String? fcmState;
  late int status;

  User.init() {
    debugPrint('User init');
  }

  static const String EMAIL = 'email';
  static const String NAME = 'name';
  static const String IMAGE = 'image';
  static const String LANGUAGE = 'language';
  static const String IS_BEGINNER_MODE = 'isBeginnerMode';
  static const String DATE_SIGN_UP = 'dataSignUp';
  static const String DATE_SIGN_IN = 'dateSignIn';
  static const String PREMIUM_RECORD = 'premiumRecord';
  static const String LESSON_RECORD = 'lessonRecord';
  static const String READING_RECORD = 'readingRecord';
  static const String FCM_TOKEN = 'fcmToken';
  static const String FCM_STATE = 'fcmState';
  static const String STATUS = 'status';

  User.fromJson(Map<String, dynamic> json) {
    email = json[EMAIL];
    name = json[NAME];
    image = json[IMAGE];
    language = json[LANGUAGE];
    isBeginnerMode = json[IS_BEGINNER_MODE];
    dateSignUp = json[DATE_SIGN_UP];
    dateSignIn = json[DATE_SIGN_IN];
    premiumRecord = json[PREMIUM_RECORD];
    lessonRecord = json[LESSON_RECORD];
    readingRecord = json[READING_RECORD];
    if(json[FCM_TOKEN] != null) {
      fcmToken = json[FCM_TOKEN];
    }
    if(json[FCM_STATE != null]) {
      fcmState = json[FCM_STATE];
    }
    status = json[STATUS];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      EMAIL: email,
      NAME: name,
      IMAGE: image,
      LANGUAGE: language,
      IS_BEGINNER_MODE: isBeginnerMode,
      DATE_SIGN_UP: dateSignUp,
      DATE_SIGN_IN: dateSignIn,
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

  Future<void> initUserWithEmail(BuildContext context) async {
    auth.User user = auth.FirebaseAuth.instance.currentUser!;
    email = user.email!;
    name = user.displayName ?? '-';
    image = user.photoURL ?? '';
    language = Localizations.localeOf(context).languageCode;
    if(!Languages().fos.contains(language)) {
      language = 'en';
    }
    isBeginnerMode = true;
    dateSignUp = DateTime.now();
    dateSignIn = DateTime.now();
    premiumRecord = [];
    lessonRecord = {};
    readingRecord = {};
    status = 0;
    Database().setDoc(collection: 'Users', doc: email);
  }

  void getUser() async {
    email = auth.FirebaseAuth.instance.currentUser!.email!;
    DocumentSnapshot<Map<String, dynamic>> snapshot = await Database().getDoc(collection: 'Users', docId: email);
    if (snapshot.exists) {
      User.fromJson(snapshot.data()!);
    } else {
      Get.dialog(AlertDialog(
        title: MyWidget().getTextWidget(text: MyStrings.failedUserTitle),
        content: MyWidget().getTextWidget(text: MyStrings.failedUserContent),
      ));
    }
  }

  void setUserEmail(String email) {
    this.email = email;
  }

  void changeUserName(String name) {
    this.name = name;
  }
}
