import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class MyWidget {
  AppBar getAppbar(BuildContext context, ResponsiveSize rs,
      {required String title, List<Widget>? actions, bool isKorean = false, bool isBold = true}) {
    return AppBar(
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Get.back();
        },
        icon: Icon(Icons.arrow_back_ios_rounded, size: rs.getSize(20)),
        color: Theme.of(context).primaryColor,
      ),
      title: Padding(
        padding: EdgeInsets.symmetric(vertical: rs.getSize(10, bigger: 1.5)),
        child: MyWidget().getTextWidget(
          rs,
          text: title,
          color: Theme.of(context).primaryColor,
          isKorean: isKorean,
          isBold: isBold,
          size: 18,
        ),
      ),
      actions: actions,
    );
  }

  Widget getSearchWidget(BuildContext context, ResponsiveSize rs,
      {required FocusNode focusNode,
      required TextEditingController controller,
      required String hint,
      required Function(String?) onChanged}) {
    return TextField(
      style: TextStyle(fontSize: rs.getSize(15), color: Theme.of(context).secondaryHeaderColor),
      focusNode: focusNode,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: rs.getSize(10)),
        prefixIcon: Icon(Icons.search, size: rs.getSize(20), color: Theme.of(context).disabledColor),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          borderSide: BorderSide(color: MyColors.navyLight, width: 1.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          borderSide: BorderSide(color: MyColors.navyLight, width: 1.0),
        ),
        hintText: hint,
        hintStyle: TextStyle(color: Theme.of(context).disabledColor),
        filled: true,
        fillColor: Theme.of(context).cardColor,
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
    bool hasCancelLine = false,
    bool isKorean = false,
    double? height,
    int? maxLine,
  }) {
    return Text(
      text ?? '',
      style: TextStyle(
        fontFamily: isKorean ? 'KoreanFont' : (Platform.isIOS ? null : 'EnglishFont'),
        fontSize: rs.getSize(size),
        color: color,
        fontWeight: isBold ? FontWeight.bold : null,
        decoration: hasUnderline
            ? TextDecoration.underline
            : hasCancelLine
                ? TextDecoration.lineThrough
                : null,
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

  Widget getTextFieldWidget(
    BuildContext context,
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
      cursorColor: Theme.of(context).secondaryHeaderColor,
      style: TextStyle(fontSize: rs.getSize(fontSize), color: Theme.of(context).secondaryHeaderColor),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        counterStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        hintMaxLines: 2,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: InputBorder.none,
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
        ),
        hintText: hint,
        hintStyle: TextStyle(fontSize: rs.getSize(fontSize), color: Theme.of(context).disabledColor),
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

  showDialog(BuildContext context, ResponsiveSize rs,
      {required String content,
      required Function yesFn,
      bool hasNoBtn = true,
      bool hasPremiumTag = false,
      String? yesText, String? noText, String? textBtnText, Function? textBtnFn}) {
    Get.dialog(AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      iconPadding: const EdgeInsets.only(bottom: 20),
      icon: hasPremiumTag
          ? Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: rs.getSize(8), vertical: rs.getSize(3)),
                  child: Row(
                    children: [
                      Icon(Icons.workspace_premium, color: Theme.of(context).primaryColor, size: 15),
                      const SizedBox(width: 5),
                      MyWidget().getTextWidget(rs,
                          text: tr('premiumOnly'), color: Theme.of(context).primaryColor, size: 13, isBold: true),
                    ],
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
      title: Center(child: Image.asset('assets/images/podo.png', width: rs.getSize(50), height: rs.getSize(50))),
      content: MyWidget().getTextWidget(rs,
          text: content, isTextAlignCenter: true, size: 16, color: Theme.of(context).secondaryHeaderColor),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: EdgeInsets.only(
          left: rs.getSize(20), right: rs.getSize(20), bottom: rs.getSize(20), top: rs.getSize(10)),
      actions: [
        Row(
          children: [
            hasNoBtn
                ? Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          side: BorderSide(color: Theme.of(context).canvasColor, width: 1),
                          backgroundColor: Theme.of(context).cardColor),
                      onPressed: () {
                        Get.back();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: rs.getSize(13)),
                        child: Text(noText ?? tr('no'),
                            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: rs.getSize(15))),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            SizedBox(width: rs.getSize(hasNoBtn ? 15 : 0)),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: Theme.of(context).canvasColor, width: 1),
                    backgroundColor: Theme.of(context).canvasColor),
                onPressed: () {
                  Get.back();
                  yesFn();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: rs.getSize(13)),
                  child: Text(yesText ?? tr('yes'),
                      style: TextStyle(color: Theme.of(context).cardColor, fontSize: rs.getSize(15))),
                ),
              ),
            ),
          ],
        ),
        textBtnText != null
            ? Center(
                child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: TextButton(
                  onPressed: () {
                    if(textBtnFn != null) {
                      textBtnFn();
                    }
                  },
                  child: MyWidget()
                      .getTextWidget(rs, text: textBtnText, color: Theme.of(context).primaryColor),
                ),
              ))
            : const SizedBox.shrink(),
      ],
    ));
  }

  showSimpleDialog(String title, String content) {
    Get.dialog(AlertDialog(
      title: Text(title,
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: Text(content, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
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
      {String title = '',
      String content = '',
      double titleSize = 15,
      double contentSize = 15,
      int duration = 2000}) {
    Get.snackbar(
      title,
      content,
      colorText: MyColors.purple,
      backgroundColor: Colors.white,
      icon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Image.asset('assets/images/podo.png',
            height: rs.getSize(40, bigger: 2), width: rs.getSize(40, bigger: 2)),
      ),
      duration: Duration(milliseconds: duration),
    );
  }

  Widget getLoading(BuildContext context, ResponsiveSize rs, double progressValue) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rs.getSize(50)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyWidget().getTextWidget(rs, text: 'Loading', color: Theme.of(context).primaryColor),
                  SizedBox(width: rs.getSize(5)),
                  SpinKitThreeBounce(color: Theme.of(context).primaryColor, size: rs.getSize(10)),
                ],
              ),
              SizedBox(height: rs.getSize(10)),
              LinearProgressIndicator(
                value: progressValue,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                color: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).cardColor,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            'assets/images/background.png', // 이미지 파일 경로
            fit: BoxFit.cover, // 화면에 맞게 이미지 크기 조절
          ),
        ),
      ],
    );
  }
}
