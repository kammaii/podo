import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  AppBar getAppbar({required String title}) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Get.back();
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

  Widget getSearchWidget(
      {required FocusNode focusNode,
      required TextEditingController controller,
      required String hint,
      required Function(String?) onChanged}) {
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
        fillColor: Colors.white,
      ),
      controller: controller,
      onChanged: onChanged,
    );
  }

  Text getTextWidget({
    required String text,
    double size = 15,
    Color color = Colors.black,
    bool? isBold,
    bool? isTextAlignCenter,
    bool hasLineThrough = false,
    bool isKorean = false,
    double? height,
    int? maxLine,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: isKorean ? 'KoreanFont' : 'EnglishFont',
        fontSize: size,
        color: color,
        fontWeight: isBold != null ? FontWeight.bold : null,
        decoration: hasLineThrough ? TextDecoration.lineThrough : null,
        height: height,
      ),
      textAlign: isTextAlignCenter != null ? TextAlign.center : null,
      maxLines: maxLine,
      overflow: maxLine != null ? TextOverflow.ellipsis : null,
    );
  }

  Widget getRoundBtnWidget({
    required String text,
    required Color bgColor,
    required Color fontColor,
    required Function f,
    double innerVerticalPadding = 13,
    int? podoCount,
    double textSize = 20,
    bool hasNullFunction = false,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: bgColor),
      onPressed: hasNullFunction
          ? f()
          : () {
              f();
            },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: innerVerticalPadding),
        child: Text(
          text,
          style: TextStyle(fontSize: textSize, color: fontColor),
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
                color: MyColors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1)),
          ]),
    );
  }

  Widget getTextFieldWidget({
    required String hint,
    required double fontSize,
    TextEditingController? controller,
    int? maxLines,
    int? maxLength,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      cursorColor: Colors.black,
      style: TextStyle(fontSize: fontSize),
      onChanged: onChanged,
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

  Widget getCheckBox({required bool value, required Function(bool?) onChanged}) {
    return Checkbox(
      value: value,
      onChanged: onChanged,
      activeColor: MyColors.purple,
    );
  }

  Widget getRoundedContainer({
    required Widget widget,
    double radius = 10,
    EdgeInsetsGeometry padding = const EdgeInsets.all(10),
    Color bgColor = Colors.white,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: widget,
    );
  }
}
