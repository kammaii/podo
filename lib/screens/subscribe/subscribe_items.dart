import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:podo/values/my_strings.dart';

class SubscribeItems {

  List<SubscribeItem> items = [
    SubscribeItem(FontAwesomeIcons.vial, MyStrings.freeTrial, MyStrings.freeTrialDetail),
    SubscribeItem(FontAwesomeIcons.unlockAlt, MyStrings.unlockLessons, MyStrings.unlockLessonsDetail),
    SubscribeItem(FontAwesomeIcons.coins, MyStrings.getPodoCoins, MyStrings.getPodoCoinsDetail),
  ];
}

class SubscribeItem {
  late IconData icon;
  late String title;
  late String description;

  SubscribeItem(this.icon, this.title, this.description);
}