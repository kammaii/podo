import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/screens/message/podo_message.dart';

class MyPageController extends GetxController {
  List<bool> modeToggle = [true, false];
  var themeMode = ThemeMode.system.obs;
  final IS_DARK_MODE = 'isDarkMode';


  void loadThemeMode() {
    if(LocalStorage().getBoolFromLocalStorage(key: IS_DARK_MODE)) {
      modeToggle = [true, false];
      themeMode.value = ThemeMode.dark;
    } else {
      modeToggle = [false, true];
      themeMode.value = ThemeMode.system;
    }
  }

  changeMode(int index) {
    bool isDarkMode = 0 == index;
    modeToggle[0] = isDarkMode;
    modeToggle[1] = !isDarkMode;
    if(isDarkMode) {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.system;
    }
    LocalStorage().setBoolToLocalStorage(key: IS_DARK_MODE, value: isDarkMode);
    update();
  }
}
