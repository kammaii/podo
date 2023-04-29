import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/profile/premium.dart';
import 'package:podo/values/my_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:podo/common/database.dart';


class User{
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
  late String fcmToken;
  late String fcmState;

  User.init() {
    getUser();
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
  static const String FCM_TOKEN = 'fcmToken';
  static const String FCM_STATE = 'fcmState';

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
    fcmToken = json[FCM_TOKEN];
    fcmState = json[FCM_STATE];
  }

  Map<String, dynamic> toJson() {
    return {
      EMAIL: email,
      NAME: name,
      IMAGE: image,
      LANGUAGE: language,
      IS_BEGINNER_MODE: isBeginnerMode,
      DATE_SIGN_UP: dateSignUp,
      DATE_SIGN_IN: dateSignIn,
      LESSON_RECORD: lessonRecord,
      FCM_TOKEN: fcmToken,
      FCM_STATE: fcmState,
    };
  }

  void initUser() {

  }

  void setUser() {

  }

  void getUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    email = pref.getString('email')!;
    DocumentSnapshot<Map<String, dynamic>> snapshot = await Database().getDoc(collection: 'Users', docId: email);
    if(snapshot.exists) {
      User.fromJson(snapshot.data()!);
    } else {
      Get.dialog(AlertDialog(
        title: MyWidget().getTextWidget(text: MyStrings.failedUserTitle),
        content: MyWidget().getTextWidget(text: MyStrings.failedUserContent),
      ));
    }
  }

  void changeUserName(String name) {
    this.name = name;
  }
}