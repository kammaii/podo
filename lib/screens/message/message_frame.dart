import 'package:flutter/material.dart';
import 'package:podo/common_widgets/my_info_widget.dart';
import 'package:podo/common_widgets/my_text_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    //todo: 최신 메시지부터 10개씩 나눠서 로딩하기
    msgList = [];
    msgList.add(Message(true, '#${MyStrings.correction}', MyStrings.lorem, '2021년 11월 29일'));
    msgList.add(Message(false, '#${MyStrings.correction}', MyStrings.lorem, '2021년 11월 29일'));

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            if(msgList.isEmpty)
            MyInfoWidget().getMyInfoWidget(40, MyStrings.messageInfo),
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
}

Widget getMsgItem(bool isUserMsg, String image, String tag, String msg, String date) {
  List<Widget> widgets;
  Color msgColor;
  if (isUserMsg) {
    msgColor = MyColors.navyLight;
    widgets = [
      imageContainer(image),
      const SizedBox(width: 10),
      Expanded(child: msgContainer(isUserMsg, tag, msg, msgColor, date))
    ];
  } else {
    msgColor = MyColors.pink;
    widgets = [
      Expanded(child: msgContainer(isUserMsg, tag, msg, msgColor, date)),
      const SizedBox(width: 10),
      imageContainer(image),
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
        if(!isUserMsg)
        const Divider(height: 30,),
      ],
    ),
  );
}

Widget imageContainer(String image) {
  return Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: MyColors.navyLight, //todo: 지우기
      shape: BoxShape.circle,
      image: DecorationImage(
        image: AssetImage(image),
        fit: BoxFit.cover,
      ),
    ),
  );
}

Widget msgContainer(bool isUserMsg, String tag, String msg, Color msgColor, String date) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if(isUserMsg)
      MyTextWidget().getTextWidget(tag, 13, MyColors.grey),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: msgColor,
        ),
        child: MyTextWidget().getTextWidget(msg, 15, Colors.black),
      ),
      Align(
        alignment: Alignment.topRight,
        child: MyTextWidget().getTextWidget(date, 13, MyColors.grey),
      ),
    ],
  );
}
