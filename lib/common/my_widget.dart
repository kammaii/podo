import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class MyWidget {
  AppBar getAppbarWithAction({
    required String title,
    required Function actionFunction,
    required Color actionColor,
  }) {
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

  AppBar getAppbar({
    required BuildContext context,
    required String title,
  }) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
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

  Widget getSearchWidget({
    required FocusNode focusNode,
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      focusNode: focusNode,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          prefixIcon: const Icon(Icons.search),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide(color: MyColors.navyLight, width: 1.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide(color: MyColors.navyLight, width: 1.0),
          ),
          hintText: hint,
          filled: true,
          fillColor: Colors.white),
      controller: controller,
    );
  }

  Text getTextWidget({
    required String text,
    required double size,
    required Color color,
    bool? isBold,
    bool? isTextAlignCenter,
    bool? isLineThrough,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: color,
        fontWeight: isBold != null ? FontWeight.bold : null,
        decoration: isLineThrough != null ? TextDecoration.lineThrough : null,
      ),
      textAlign: isTextAlignCenter != null ? TextAlign.center : null,
    );
  }

  Widget getInfoWidget({
    required double height,
    required String info,
  }) {
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
        child: Center(child: getTextWidget(text: info, size: 15, color: MyColors.greenDark)),
      ),
    );
  }

  Widget getRoundBtnWithAlert({
    required bool isRequest,
    required String text,
    required Color bgColor,
    required Color fontColor,
    required Function f,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.center,
          child: getRoundBtnWidget(
            isRequest: isRequest,
            text: text,
            bgColor: bgColor,
            fontColor: fontColor,
            f: f,
          ),
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
                MyStrings.notEnoughCoins,
                style: TextStyle(color: MyColors.purple, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  MyStrings.howToGetCoins,
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

  Widget getRoundBtnWidget({
    required bool isRequest,
    required String text,
    required Color bgColor,
    required Color fontColor,
    required Function f,
    double? horizontalPadding,
    double? innerVerticalPadding,
    int? podoCount,
  }) {
    if (horizontalPadding == null) {
      return roundBtnWidget(
        isRequest: isRequest,
        text: text,
        bgColor: bgColor,
        fontColor: fontColor,
        f: f,
        innerVerticalPadding: innerVerticalPadding,
        podoCount: podoCount,
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: roundBtnWidget(
                isRequest: isRequest,
                text: text,
                bgColor: bgColor,
                fontColor: fontColor,
                f: f,
                innerVerticalPadding: innerVerticalPadding,
              ),
            ),
          )
        ],
      );
    }
  }

  Widget roundBtnWidget({
    required bool isRequest,
    required String text,
    required Color bgColor,
    required Color fontColor,
    required Function f,
    double? innerVerticalPadding,
    int? podoCount,
  }) {
    double verticalPadding;
    isRequest ? verticalPadding = 5 : verticalPadding = 13;
    if (innerVerticalPadding != null) {
      verticalPadding = innerVerticalPadding;
    }
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
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: verticalPadding),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 20, color: fontColor),
            ),
            if (isRequest)
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
                        children: [
                          const Icon(CupertinoIcons.ticket),
                          const SizedBox(width: 5),
                          Text(podoCount.toString()),
                        ],
                      )
                    ],
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget getCircleImageWidget({
    required String image,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
                color: MyColors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 1)),
          ]),
    );
  }

  Widget getTextFieldWidget({
    required String hint,
    required double fontSize,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      maxLines: null,
      cursorColor: Colors.black,
      style: TextStyle(fontSize: fontSize),
      decoration: InputDecoration(
        hintMaxLines: 2,
        filled: true,
        fillColor: Colors.white,
        border: InputBorder.none,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: MyColors.navyLight, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: MyColors.navyLight, width: 1),
        ),
        hintText: hint,
        hintStyle: TextStyle(fontSize: fontSize),
        contentPadding: const EdgeInsets.all(10),
      ),
    );
  }
}
