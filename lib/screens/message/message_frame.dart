import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podo/common_widgets/my_widget.dart';
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
  late bool isInfoClicked;
  late Color infoIconColor;
  late double infoHeight;
  bool isPremiumUser = true; //todo: DB에서 받아오기
  String? selectedTag;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    controller = TextEditingController();
    msgList = [];
    msgList.add(Message(
        true, '#${MyStrings.correction}', MyStrings.lorem, '2021년 11월 29일'));
    msgList.add(Message(
        false, '#${MyStrings.correction}', MyStrings.lorem, '2021년 11월 29일'));
    msgList.isEmpty ? isInfoClicked = true : isInfoClicked = false;
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
      infoIconColor = MyColors.green;
      infoHeight = 80;
    } else {
      infoIconColor = MyColors.grey;
      infoHeight = 0;
    }

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            MyWidget().getInfoWidget(infoHeight, MyStrings.messageInfo),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: MyWidget().getSearchWidget(
                        focusNode, controller, MyStrings.messageSearchHint),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      CupertinoIcons.ticket, color: MyColors.purple,),
                  ),
                  MyWidget().getTextWidget(
                      '3', 15, MyColors.purple, isBold: true),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isInfoClicked = !isInfoClicked;
                      });
                    },
                    icon: Icon(
                      CupertinoIcons.info_circle_fill, color: infoIconColor,),
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
                  String image = isUserMsg
                      ? 'assets/images/course_hangul.png'
                      : 'assets/images/logo.png';
                  String tag = msgList[index].tag;
                  String msg = msgList[index].msg;
                  String date = msgList[index].date;
                  return getMsgItem(isUserMsg, image, tag, msg, date);
                },
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      children: [
                        getTagBtn(MyStrings.tagCorrection, () {
                          setState(() {
                            selectedTag = MyStrings.tagCorrection;
                          });
                        }),
                        const SizedBox(width: 5),
                        getTagBtn(MyStrings.tagQuestion, () {
                          setState(() {
                            selectedTag = MyStrings.tagQuestion;
                          });
                        }),
                        const SizedBox(width: 5),
                        getTagBtn(MyStrings.tagNotice, () {
                          setState(() {
                            selectedTag = MyStrings.tagNotice;
                          });
                        }),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white, height: 20,),
                  if(selectedTag != null && selectedTag != MyStrings.tagNotice)
                    getExpandWidget(isPremiumUser, selectedTag!, (){}),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getExpandWidget(bool isPremiumUser, String tag, Function f) {
    String hint = '';

    if(isPremiumUser) {
      switch (tag) {
        case MyStrings.tagCorrection :
          hint = MyStrings.correctionHint;
          break;

        case MyStrings.tagQuestion :
          hint = MyStrings.questionHint;
          break;
      }
      return Column(
        children: [
          const Align(
            alignment: Alignment.topRight,
            child: Text('0/30')
          ),
          const SizedBox(height: 5),
          MyWidget().getTextFieldWidget(hint, 15),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: MyWidget().getRoundBtnWidget(
                true, MyStrings.send, MyColors.purple, Colors.white, f()),
          )
        ],
      );

    } else {
      return MyWidget().getRoundBtnWidget(
        false, MyStrings.podoPremium, MyColors.purple, Colors.white, f(), horizontalPadding: 5,
      );
    }
  }


  Widget getTagBtn(String text, Function f) {
    return ElevatedButton(
      onPressed: () {
        f();
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        primary: MyColors.green,
      ),
      child: Text(text),
    );
  }

  Widget getMsgItem(bool isUserMsg, String image, String tag, String msg,
      String date) {
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
