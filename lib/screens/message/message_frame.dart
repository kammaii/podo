import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:podo/common_widgets/my_widget.dart';
import 'package:podo/screens/message/action_button.dart';
import 'package:podo/screens/message/expandable_fab.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'message.dart';

class MessageFrame extends StatefulWidget {
  const MessageFrame({Key? key}) : super(key: key);

  @override
  _MessageFrameState createState() => _MessageFrameState();
}

class _MessageFrameState extends State<MessageFrame> {
  String userImage = 'assets/images/logo.png';
  String podoImage = 'assets/images/logo.png';
  List<Message> msgList = [];
  late FocusNode focusNode;
  late TextEditingController controller;
  late Color infoIconColor;
  late double infoHeight;
  bool isPremiumUser = true; //todo: DB에서 받아오기
  String? selectedTag;
  late int correctionCount;

  @override
  void initState() {
    super.initState();
    correctionCount = 1;
    focusNode = FocusNode();
    controller = TextEditingController();
    msgList = [];
    msgList.add(Message(false, '#${MyStrings.correction}', MyStrings.lorem, '2021년 11월 29일'));
    msgList.add(Message(true, '#${MyStrings.correction}', MyStrings.lorem, '2021년 11월 29일'));
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //todo: 최신 메시지부터 10개씩 나눠서 로딩하기

    if (isInfoClicked) {
      infoIconColor = MyColors.grey;
      infoHeight = 80;
    } else {
      infoIconColor = MyColors.green;
      infoHeight = 0;
    }

    return SafeArea(
      child: Scaffold(
        floatingActionButton: ExpandableFab(
          distance: 80,
          children: [
            ActionButton(
              onPressed: () {
                Get.bottomSheet(
                  getBottomSheet(isPremiumUser, MyStrings.tagCorrection, (){}),
                );
              },
              icon: const Icon(Icons.message_rounded),
            ),
            ActionButton(
              onPressed: () {
                Get.bottomSheet(
                  getBottomSheet(isPremiumUser, MyStrings.tagQuestion, (){}),
                );
              },
              icon: const Icon(FontAwesomeIcons.question),
            ),
          ],
        ),
        body: Column(
          children: [
            MyWidget().getInfoWidget(infoHeight, MyStrings.messageInfo),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: MyWidget().getSearchWidget(focusNode, controller, MyStrings.messageSearchHint),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      CupertinoIcons.ticket,
                      color: MyColors.purple,
                    ),
                  ),
                  MyWidget().getTextWidget('3', 15, MyColors.purple, isBold: true),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isInfoClicked = !isInfoClicked;
                      });
                    },
                    icon: Icon(
                      CupertinoIcons.info_circle_fill,
                      color: infoIconColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: msgList.length,
                itemBuilder: (BuildContext context, int index) {
                  bool isUserMsg = msgList[index].isUserMsg;
                  String image = isUserMsg ? 'assets/images/course_hangul.png' : 'assets/images/logo.png';
                  String tag = msgList[index].tag;
                  String msg = msgList[index].msg;
                  String date = msgList[index].date;
                  return getMsgItem(isUserMsg, image, tag, msg, date);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getBottomSheet(bool isPremiumUser, String tag, Function f) {
    String hint = '';
    bool isCorrection = false;

    switch (tag) {
      case MyStrings.tagCorrection:
        isCorrection = true;
        hint = MyStrings.correctionHint;
        break;

      case MyStrings.tagQuestion:
        hint = MyStrings.questionHint;
        break;
    }
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyWidget().getTextWidget(tag, 20, MyColors.purple),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark), color: MyColors.purple,
                  onPressed: (){Get.back();},
                )
              ],
            ),
            const SizedBox(height: 10),
            const Align(alignment: Alignment.topRight, child: Text('0/30')),
            const SizedBox(height: 10),
            getTextField(hint, isCorrection),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: MyWidget().getRoundBtnWidget(true, MyStrings.send, MyColors.purple, Colors.white, f()),
            )
          ],
        ),
      ),
    );
  }

  Widget getTextField(String hint, bool isCorrection) {
    if(isCorrection) {
      return Column(
        children: [
          MyWidget().getTextFieldWidget(hint, 15),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: MyColors.purple,),
            onPressed: () {
              setState(() {
                //todo: textField 추가
              });
            },
          ),
        ],
      );
    } else {
      return MyWidget().getTextFieldWidget(hint, 15);
    }
  }

  Widget getMsgItem(bool isUserMsg, String image, String tag, String msg, String date) {
    List<Widget> widgets;
    Color msgColor;
    if (isUserMsg) {
      msgColor = MyColors.navyLight;
      widgets = [
        MyWidget().getCircleImageWidget(image, 50),
        const SizedBox(width: 10),
        Expanded(child: msgContainer(isUserMsg, tag, msg, msgColor, date))
      ];
    } else {
      msgColor = MyColors.pink;
      widgets = [
        Expanded(child: msgContainer(isUserMsg, tag, msg, msgColor, date)),
        const SizedBox(width: 10),
        MyWidget().getCircleImageWidget(image, 50),
      ];
    }
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          ),
          if (!isUserMsg)
            const Divider(
              height: 30,
            ),
        ],
      ),
    );
  }

  Widget msgContainer(bool isUserMsg, String tag, String msg, Color msgColor, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isUserMsg) MyWidget().getTextWidget(tag, 13, MyColors.grey),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: msgColor,
          ),
          child: MyWidget().getTextWidget(msg, 15, Colors.black),
        ),
        Align(
          alignment: Alignment.topRight,
          child: MyWidget().getTextWidget(date, 13, MyColors.grey),
        ),
      ],
    );
  }
}
