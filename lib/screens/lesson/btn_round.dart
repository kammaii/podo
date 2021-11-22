import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podo/values/my_colors.dart';

class RoundBtn {
  late Function callback;

  Widget getRoundBtn(bool isRequest, String text, Color bgColor, Color fontColor, Function f) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          primary: bgColor),
      onPressed: () {
        f();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: isRequest? 5:13),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 20, color: fontColor),
            ),
            if(isRequest)
            Row(
              children: [
                const SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    color: Colors.white,
                    thickness: 1,
                    width: 20,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('consume'),
                    Row(
                      children: const [
                        Icon(CupertinoIcons.ticket),
                        SizedBox(width: 5),
                        Text('2'),
                      ],
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
