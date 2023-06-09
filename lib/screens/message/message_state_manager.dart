import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/items/message.dart';
import 'package:podo/items/notice.dart';
import 'package:podo/screens/profile/user_info.dart';
import 'package:podo/screens/message/message_frame.dart';

class MessageStateManager extends GetxController {
  late List<Message> msgList;
  late List<Notice> noticeList;
  late FocusNode focusNode;
  late TextEditingController searchController;
  late bool isPremiumUser;
  late int correctionCount;
  late int thisSwiperIndex;
  late int checkedAnswer;
  late bool isLiveLessonChecked;


  @override
  void onInit() {
    msgList = []; //todo: 최신 메시지부터 10개씩 나눠서 로딩하기
    noticeList = SampleNotice().getNotices(); //todo: DB에서 isOnBoard = true 가져오기
    focusNode = FocusNode();
    searchController = TextEditingController();
    //isPremiumUser = User().isPremium;
    correctionCount = 1;
    thisSwiperIndex = 0;
    checkedAnswer = 0;
    isLiveLessonChecked = false;
    //msgList.add(Message(false, '', MyStrings.messageInfo, ''));
    //todo: 이후의 메시지는 DB에서 가져오기
    // msgList.add(Message(true, '#${MyStrings.correction}', MyStrings.lorem, '2021년 11월 29일'));
    // msgList.add(Message(false, '#${MyStrings.correction}', MyStrings.lorem, '2021년 11월 29일'));
  }


  void disposeControllers() {
    focusNode.dispose();
    searchController.dispose();
    update();
  }
}