import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/screens/message/podo_message.dart';

class MyPageController extends GetxController {
  List<bool> modeToggle = [true, false];
  var themeMode = ThemeMode.system.obs;

  void loadThemeMode() {
    if(LocalStorage().prefs != null && LocalStorage().getThemeMode()) {
      modeToggle = [true, false];
      themeMode.value = ThemeMode.dark;
    } else {
      modeToggle = [false, true];
      themeMode.value = ThemeMode.system;
    }
  }

  changeMode(int index) {
    modeToggle[0] = 0 == index;
    modeToggle[1] = 1 == index;
    index == 0 ? themeMode.value = ThemeMode.dark : themeMode.value = ThemeMode.system;
    LocalStorage().setThemeMode(index == 0);
    update();
  }
}
