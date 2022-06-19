import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UserInfo extends GetxController{

  static final UserInfo _instance = UserInfo.init();

  factory UserInfo() {
    return _instance;
  }

  late String email;
  late String name;
  late bool isPremium;
  late int podo;
  late List<String> favorites;


  void setCoins(int coin) {
    podo = coin;
  }

  UserInfo.init() {
    debugPrint('userInfo 초기화');
    //todo: DB에서 받아오기
    email = 'danny@gmail.com';
    name = 'danny';
    isPremium = false;
    podo = 3;
    favorites = [];
  }

  void changeUserName(String name) {
    this.name = name;
  }

  void setIsPremium(bool isPremium) {
    this.isPremium = isPremium;
  }

  void addFavorite(String favorite) {
    favorites.add(favorite);
    update();
  }

  void removeFavorite(String favorite) {
    favorites.remove(favorite);
    update();
  }
}