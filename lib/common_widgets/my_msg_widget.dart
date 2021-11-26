import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class MyMsgWidget {

  Widget getMsgAlert() {
    return Container(
      decoration: const BoxDecoration(
        color: MyColors.pink,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            MyStrings.notEnoughTickets,
            style: TextStyle(
                color: MyColors.purple, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              MyStrings.howToGetTickets,
              style: TextStyle(
                  color: MyColors.red,
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                  decorationThickness: 2),
            ),
          ),
        ],
      ),
    );
  }
}