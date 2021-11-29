import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podo/common_widgets/my_widget.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class LessonCorrection extends StatefulWidget {
  const LessonCorrection({Key? key}) : super(key: key);

  @override
  _LessonCorrectionState createState() => _LessonCorrectionState();
}

class _LessonCorrectionState extends State<LessonCorrection> {
  bool isInfoSelected = false;
  Color infoIconColor = MyColors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyWidget().getAppbarWithAction(
        MyStrings.correction,
        () {
          setState(() {
            if (isInfoSelected) {
              isInfoSelected = false;
              infoIconColor = MyColors.grey;
            } else {
              isInfoSelected = true;
              infoIconColor = MyColors.green;
            }
          });
        },
        infoIconColor
      ),
      body: SafeArea(
        child: Column(
          children: [
            MyWidget().getInfoWidget(
                isInfoSelected ? 60 : 0, MyStrings.correctionInfo),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  CupertinoIcons.ticket,
                  color: MyColors.purple,
                ),
                const SizedBox(width: 5),
                MyWidget()
                    .getTextWidget('3', 18, MyColors.purple, isBold: true),
                const SizedBox(width: 10),
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        children: [
                          correctionCard(),
                          correctionCard(),
                          correctionCard(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: MyWidget().getRoundBtnWithAlert(
                      true,
                      MyStrings.send,
                      MyColors.green,
                      Colors.white,
                      () {

                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget correctionCard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MyWidget().getTextWidget('1) ~을 거예요', 20, MyColors.purple,
                  isBold: true),
              MyWidget().getTextWidget('3/30', 13, MyColors.grey),
            ],
          ),
          const SizedBox(height: 10),
          const TextField(
            maxLines: null,
            cursorColor: Colors.black,
            style: TextStyle(fontSize: 18),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: MyColors.navyLight, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: MyColors.navyLight, width: 1),
              ),
              hintText: MyStrings.correctionHint,
              hintStyle: TextStyle(fontSize: 15),
              contentPadding: EdgeInsets.all(10),
            ),
          ),
        ],
      ),
    );
  }
}
