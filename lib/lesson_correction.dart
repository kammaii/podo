import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:podo/request_btn.dart';

import 'my_colors.dart';

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
          'Correction',
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
              padding: const EdgeInsets.fromLTRB(10,10,10,0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
                height: isInfoSelected ? 60 : 0,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: MyColors.greenLight,
                ),
                child: const Center(
                  child: Text(
                    'Try making your own sentence and get correction from a professional Korean teacher by using a ticket.',
                    style: TextStyle(
                      color: MyColors.greenDark,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(
                  CupertinoIcons.ticket,
                  color: MyColors.purple,
                ),
                SizedBox(width: 5),
                Text(
                  '3',
                  style: TextStyle(
                      color: MyColors.purple, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
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
                  RequestBtn().getRequestBtn('Send'),
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
        children: const [
          Text(
            '1) ~을 거예요',
            style: TextStyle(
              fontSize: 20,
              color: MyColors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          TextField(
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
              hintText: 'Make your sentence',
              hintStyle: TextStyle(fontSize: 15),
              contentPadding: EdgeInsets.all(10),
            ),
          ),
        ],
      ),
    );
  }
}
