import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class MyWidget {

  AppBar getAppbar(ResponsiveSize rs,
      {required String title, List<Widget>? actions, bool isKorean = false, bool isBold = true}) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Get.back();
        },
        icon: Icon(Icons.arrow_back_ios_rounded, size: rs.getSize(20)),
        color: MyColors.purple,
      ),
      title: Padding(
        padding: EdgeInsets.symmetric(vertical: rs.getSize(10, bigger: 1.5)),
        child: MyWidget().getTextWidget(
          rs,
          text: title,
          color: MyColors.purple,
          isKorean: isKorean,
          isBold: isBold,
          size: 18,
        ),
      ),
      actions: actions,
    );
  }

  Widget getSearchWidget(ResponsiveSize rs,
      {required FocusNode focusNode,
      required TextEditingController controller,
      required String hint,
      required Function(String?) onChanged}) {
    return TextField(
      style: TextStyle(fontSize: rs.getSize(15)),
      focusNode: focusNode,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: rs.getSize(10)),
        prefixIcon: Icon(Icons.search, size: rs.getSize(20)),
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

  Text getTextWidget(
    ResponsiveSize rs, {
    required String? text,
    double size = 15,
    Color color = Colors.black,
    bool isBold = false,
    bool isTextAlignCenter = false,
    bool hasUnderline = false,
    bool isKorean = false,
    double? height,
    int? maxLine,
  }) {
    return Text(
      text ?? '',
      style: TextStyle(
        fontFamily: isKorean ? 'KoreanFont' : 'EnglishFont',
        fontSize: rs.getSize(size),
        color: color,
        fontWeight: isBold ? FontWeight.bold : null,
        decoration: hasUnderline ? TextDecoration.underline : null,
        height: height,
      ),
      textAlign: isTextAlignCenter ? TextAlign.center : null,
      maxLines: maxLine,
      overflow: maxLine != null ? TextOverflow.ellipsis : null,
    );
  }

  Widget getRoundBtnWidget(
    ResponsiveSize rs, {
    required String text,
    Color bgColor = MyColors.purple,
    Color fontColor = Colors.white,
    required Function f,
    double verticalPadding = 13,
    double horizontalPadding = 10,
    double textSize = 20,
    bool hasNullFunction = false,
    double borderRadius = 30,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          backgroundColor: bgColor),
      onPressed: hasNullFunction
          ? f()
          : () {
              f();
            },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: rs.getSize(horizontalPadding), vertical: verticalPadding),
        child: MyWidget().getTextWidget(rs, text: text, size: rs.getSize(textSize), color: fontColor),
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

  Widget getTextFieldWidget(
    ResponsiveSize rs, {
    String hint = '',
    double fontSize = 15,
    TextEditingController? controller,
    int? maxLines,
    int? maxLength,
    Function(String)? onChanged,
    bool enabled = true,
    FocusNode? focusNode,
    Function(String)? onSubmitted,
    Key? key,
  }) {
    return TextField(
      key: key,
      focusNode: focusNode,
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      cursorColor: Colors.black,
      style: TextStyle(fontSize: rs.getSize(fontSize)),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
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
        hintStyle: TextStyle(fontSize: rs.getSize(fontSize)),
        contentPadding: EdgeInsets.all(rs.getSize(10)),
      ),
    );
  }

  Widget getCheckBox(ResponsiveSize rs, {required bool value, required Function(bool?) onChanged}) {
    return Transform.scale(
      scale: rs.getSize(1),
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: MyColors.purple,
      ),
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

  showDialog(ResponsiveSize rs, {required String content, required Function yesFn}) {
    Get.dialog(AlertDialog(
      title: Image.asset('assets/images/podo.png', width: rs.getSize(50), height: rs.getSize(50)),
      content: MyWidget().getTextWidget(rs, text: content, isTextAlignCenter: true, size: 16),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding:
          EdgeInsets.only(left: rs.getSize(20), right: rs.getSize(20), bottom: rs.getSize(20), top: rs.getSize(10)),
      actions: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: const BorderSide(color: MyColors.purple, width: 1),
                    backgroundColor: Colors.white),
                onPressed: () {
                  Get.back();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: rs.getSize(13)),
                  child: Text(tr('no'), style: TextStyle(color: MyColors.purple, fontSize: rs.getSize(15))),
                ),
              ),
            ),
            SizedBox(width: rs.getSize(15)),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: const BorderSide(color: MyColors.purple, width: 1),
                    backgroundColor: MyColors.purple),
                onPressed: () {
                  Get.back();
                  yesFn();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: rs.getSize(13)),
                  child: Text(tr('yes'), style: TextStyle(color: Colors.white, fontSize: rs.getSize(15))),
                ),
              ),
            ),
          ],
        )
      ],
    ));
  }

  showSnackbar(
    ResponsiveSize rs, {
    String title = '',
    String message = '',
    double titleSize = 15,
    double messageSize = 15,
    Color bgColor = Colors.white,
    Color textColor = MyColors.purple,
  }) {
    Get.snackbar(
      title,
      message,
      titleText: MyWidget().getTextWidget(rs, text: title, size: titleSize),
      messageText: MyWidget().getTextWidget(rs, text: message, size: messageSize),
      backgroundColor: bgColor,
      colorText: textColor,
      duration: const Duration(seconds: 5),
    );
  }

  showSnackbarWithPodo(ResponsiveSize rs,
      {String title = '', String content = '', double titleSize = 15, double contentSize = 15, int duration = 2000}) {
    Get.snackbar(
      title,
      content,
      colorText: MyColors.purple,
      backgroundColor: Colors.white,
      icon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Image.asset('assets/images/podo.png', height: rs.getSize(40, bigger: 2), width: rs.getSize(40, bigger: 2)),
      ),
      duration: Duration(milliseconds: duration),
    );
  }

  Widget getLoading(ResponsiveSize rs, double progressValue) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs.getSize(50)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyWidget().getTextWidget(rs, text: 'Loading', color: MyColors.purple),
              SizedBox(width: rs.getSize(5)),
              SpinKitThreeBounce(color: MyColors.purple, size: rs.getSize(10)),
            ],
          ),
          SizedBox(height: rs.getSize(10)),
          LinearProgressIndicator(
            value: progressValue,
            valueColor: const AlwaysStoppedAnimation<Color>(MyColors.purple),
            backgroundColor: MyColors.navyLight,
          ),
        ],
      ),
    );
  }
}
