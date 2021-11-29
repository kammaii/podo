import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class MyWidget {

  AppBar getAppbarWithAction(String title, Function actionFunction, Color actionColor) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.arrow_back_ios_rounded),
        color: MyColors.purple,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: MyColors.purple,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () {
              actionFunction();
            },
            icon: const Icon(CupertinoIcons.info_circle_fill),
            color: actionColor,
          ),
        )
      ],
    );
  }

  AppBar getAppbar(String title) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.arrow_back_ios_rounded),
        color: MyColors.purple,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: MyColors.purple,
        ),
      ),
    );
  }

  Widget getSearchWidget(FocusNode focusNode, TextEditingController controller) {
    return TextField(
      focusNode: focusNode,
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          prefixIcon: Icon(Icons.search),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(30.0)),
            borderSide: BorderSide(
                color: MyColors.navyLight,
                width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(30.0)),
            borderSide: BorderSide(
                color: MyColors.navyLight,
                width: 1.0),
          ),
          hintText: MyStrings.questionSearchHint,
          filled: true,
          fillColor: Colors.white
      ),
      controller: controller,
    );
  }

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

  Widget getInfoWidget(double height, String info) {
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
            child: getTextWidget(info, 15, MyColors.greenDark)
        ),
      ),
    );
  }

  Widget getRoundBtnWithAlert(bool isRequest, String text, Color bgColor, Color fontColor, Function f) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Align(
          child: getRoundBtnWidget(isRequest, text, bgColor, fontColor, f),
          alignment: Alignment.center,
        ),
        const SizedBox(height: 10),
        Container(
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
        ),
      ],
    );
  }

  Widget getRoundBtnWidget(bool isRequest, String text, Color bgColor, Color fontColor, Function f) {
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
