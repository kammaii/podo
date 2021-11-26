import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podo/common_widgets/btn_round_widget.dart';
import 'package:podo/common_widgets/my_text_widget.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: MyColors.purple,
        ),
        title: const Text(
          MyStrings.correction,
          style: TextStyle(
            color: MyColors.purple,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
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
              icon: const Icon(CupertinoIcons.info_circle_fill),
              color: infoIconColor,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
                height: isInfoSelected ? 60 : 0,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: MyColors.greenLight,
                ),
                child: Center(
                  child: MyTextWidget().getTextWidget(MyStrings.correctionInfo, 15, MyColors.greenDark)
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  CupertinoIcons.ticket,
                  color: MyColors.purple,
                ),
                const SizedBox(width: 5),
                MyTextWidget().getTextWidget('3', 18, MyColors.purple, isBold: true),
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
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: RoundBtnWidget().getRoundBtn(
                        true,
                        MyStrings.send,
                        MyColors.green,
                        Colors.white,
                        () {},
                      ),
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
          MyTextWidget().getTextWidget('1) ~을 거예요', 20, MyColors.purple, isBold: true),
          const SizedBox(height: 15),
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
