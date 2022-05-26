import 'package:flutter/cupertino.dart';

class UserInfo {

  static final UserInfo _instance = UserInfo.init();

  factory UserInfo() {
    return _instance;
  }

  late String email;
  late String name;
  late bool isPremium;
  late int coins;

  void setCoins(int coin) {
    coins = coin;
  }

  UserInfo.init() {
    debugPrint('userInfo 초기화');
    coins = 3; //todo: DB에서 받아오기
    isPremium = false; //todo: late bool isPremium;
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