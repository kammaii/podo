import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:podo/items/lesson_title.dart';
import 'package:podo/items/podo_coin_usage.dart';
import 'package:podo/items/premium.dart';

class UserInfo extends GetxController{

  static final UserInfo _instance = UserInfo.init();

  factory UserInfo() {
    return _instance;
  }

  late String email;
  late String? name;
  late String? userImage;
  late String? country;
  late double dateSignUp;
  late double dateLastSignIn;
  late bool isPremium;
  late double? datePremiumStart;
  late double? datePremiumEnd;
  late List<Premium>? premiumRecord;
  late int podoCoin;
  late List<PodoCoinUsage>? podoCoinRecord;
  late List<LessonTitle>? completeLessons;
  late List<String>? favorites;


  void setCoins(int coin) {
    podoCoin = coin;
  }

  UserInfo.init() {
    debugPrint('userInfo 초기화');
    //todo: DB에서 받아오기
    email = 'danny@gmail.com';
    name = 'danny';
    userImage = 'assets/images/logo.png';
    isPremium = false;
    podoCoin = 3;
    favorites = [];
  }

  void changeUserName(String name) {
    this.name = name;
  }

  void setIsPremium(bool isPremium) {
    this.isPremium = isPremium;
  }

  void addFavorite(String favorite) {
    favorites!.add(favorite);
    update();
  }

  void removeFavorite(String favorite) {
    favorites!.remove(favorite);
    update();
  }
}