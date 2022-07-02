import 'package:flutter/material.dart';

class ProfileItem {
  late IconData icon;
  late String title;
  bool isExpanded = false;

  ProfileItem(this.icon, this.title);
}