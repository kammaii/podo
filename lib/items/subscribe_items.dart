import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:podo/values/my_strings.dart';

class SubscribeItems {
  List<SubscribeItem> items = [
    SubscribeItem(icon: FontAwesomeIcons.vial, title: MyStrings.freeTrial, description: MyStrings.freeTrialDetail),
    SubscribeItem(icon: FontAwesomeIcons.unlockKeyhole, title: MyStrings.unlockLessons, description: MyStrings.unlockLessonsDetail),
    SubscribeItem(icon: FontAwesomeIcons.coins, title: MyStrings.getPodoCoins, description: MyStrings.getPodoCoinsDetail),
  ];
}

class SubscribeItem {
  late IconData icon;
  late String title;
  late String description;

  SubscribeItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
