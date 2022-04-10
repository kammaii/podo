import 'package:flutter/cupertino.dart';

class UserInfo {

  static final UserInfo _instance = UserInfo.init();

  factory UserInfo() {
    return _instance;
  }

  late String email;
  late String name;
  bool isPremium = false; //todo: late bool isPremium;

  UserInfo.init() {
    debugPrint('userInfo 초기화');
  }

  void setUserEmail(String email) {
    this.email = email;
  }

  void setUserName(String name) {
    this.name = name;
  }

  void setUserPremium(bool isPremium) {
    this.isPremium = isPremium;
  }
}