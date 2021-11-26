import 'package:flutter/material.dart';

class MyTextWidget {

  Text getTextWidget(String text, double size, Color color, {bool? isBold}) {
    if(isBold != null) {
      return Text(
        text,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return Text(
        text,
        style: TextStyle(
          fontSize: size,
          color: color,
        ),
      );
    }
  }
}