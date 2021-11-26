import 'package:flutter/material.dart';
import 'package:podo/values/my_colors.dart';
import 'my_text_widget.dart';

class MyInfoWidget {

  Widget getMyInfoWidget(double height, String info) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        height: height,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: MyColors.greenLight,
        ),
        child: Center(
            child: MyTextWidget().getTextWidget(info, 15, MyColors.greenDark)
        ),
      ),
    );
  }
}