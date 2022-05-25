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
  late TextEditingController _searchController;
  late double notificationHeight;
  late bool isNotificationClicked;
  bool isPremiumUser = true; //todo: DB에서 받아오기
  String? selectedTag;
  late int correctionCount;
  late List<TextFieldItem> textFieldItems;

  String notification = 'New version has been released.\n\nOnline lesson is coming soon.'; //todo: DB에서 받아오기

  @override
  void initState() {
    super.initState();
    correctionCount = 1;
    textFieldItems = [];
    focusNode = FocusNode();
    _searchController = TextEditingController();
    isNotificationClicked = false;
    msgList = [];
    msgList.add(Message(false, '', MyStrings.messageInfo, ''));
    //todo: 이후의 메시지는 DB에서 가져오기
    // msgList.add(Message(true, '#${MyStrings.correction}', MyStrings.lorem, '2021년 11월 29일'));
    // msgList.add(Message(false, '#${MyStrings.correction}', MyStrings.lorem, '2021년 11월 29일'));
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //todo: 최신 메시지부터 10개씩 나눠서 로딩하기

    notificationHeight = 120;

    return SafeArea(
      child: Scaffold(
        floatingActionButton: ExpandableFab(
          distance: 80,
          children: [
            ActionButton(
              onPressed: () {
                Get.bottomSheet(
                  getBottomSheet(MyStrings.tagCorrection, () {
                    //todo: correction 보내기
                  }),
                  isScrollControlled: true,
                );
              },
              icon: const Icon(Icons.message_rounded),
            ),
            ActionButton(
              onPressed: () {
                Get.bottomSheet(
                  getBottomSheet(MyStrings.tagQuestion, () {
                    //todo: question 보내기
                  }),
                );
              },
              icon: const Icon(FontAwesomeIcons.question),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
                height: notificationHeight,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: MyColors.greenLight,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {});
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.bullhorn,
                            color: MyColors.greenDark,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                              child:
                                  MyWidget().getTextWidget(MyStrings.notification, 15, MyColors.greenDark)),
                          const Icon(Icons.arrow_drop_down, color: MyColors.greenDark),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(notification),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: MyWidget().getSearchWidget(focusNode, _searchController, MyStrings.messageSearchHint),
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
                ],
              ),
              Expanded(
                child: ListView.builder(
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
      ),
    );
  }

  Widget getBottomSheet(String tag, Function f) {
    bool isCorrection;
    textFieldItems.clear();

    if(tag == MyStrings.tagCorrection) {
      isCorrection = true;
      textFieldItems.add(TextFieldItem(MyStrings.correctionHint, false));
    } else {
      isCorrection = false;
      textFieldItems.add(TextFieldItem(MyStrings.questionHint, false));
    }

    return StatefulBuilder(
      builder: (context, reRender) {
        List<Widget> textFieldWidgets = [];

        if(isCorrection) {
          for(int i=0; i<textFieldItems.length; i++) {
            textFieldItems[i].setRemoveFunction(() {
              reRender(() {
                int removeIdx = textFieldItems.indexWhere((element) => element.key == textFieldItems[i].key);
                textFieldItems.removeAt(removeIdx);
              });
            });
            textFieldWidgets.add(textFieldItems[i].getWidget());
          }
        } else {
          textFieldWidgets.add(textFieldItems[0].getWidget());
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
                      icon: const Icon(CupertinoIcons.xmark),
                      color: MyColors.purple,
                      onPressed: () {
                        Get.back();
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Column(children: textFieldWidgets), //todo: AnimatedList로 변경하기
                isCorrection
                  ?IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: MyColors.purple,
                    ),
                    onPressed: () {
                      reRender(() {
                        if(textFieldItems.length <= 1) {
                          for (TextFieldItem item in textFieldItems) {
                            item.hasRemoveBtn = true;
                          }
                        }
                        textFieldItems.add(TextFieldItem('',true));
                      });
                    },
                  )
                  : const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child:
                      MyWidget().getRoundBtnWidget(true, MyStrings.send, MyColors.purple, Colors.white, f),
                )
              ],
            ),
          ),
        );
      },
    );
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


class TextFieldItem {
  Key key = UniqueKey();
  late String hint;
  late bool hasRemoveBtn;
  VoidCallback? removeFunction;
  TextEditingController controller = TextEditingController();

  TextFieldItem(this.hint, this.hasRemoveBtn);

  void setRemoveFunction(VoidCallback f) {
    removeFunction = f;
  }

  Widget getWidget() {
    return Column(
      children: [
        const Align(alignment: Alignment.topRight, child: Text('0/30')),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(child: MyWidget().getTextFieldWidget(hint, 15, controller: controller)),
              const SizedBox(width: 10),
              hasRemoveBtn
                  ? IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: MyColors.purple,
                  ),
                  onPressed: removeFunction
              )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }
}
