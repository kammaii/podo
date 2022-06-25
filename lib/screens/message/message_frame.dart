import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:podo/common_widgets/my_widget.dart';
import 'package:podo/screens/message/action_button.dart';
import 'package:podo/screens/message/expandable_fab.dart';
import 'package:podo/screens/message/notice.dart';
import 'package:podo/screens/subscribe/subscribe.dart';
import 'package:podo/user/user_info.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'message.dart';

class MessageFrame extends StatelessWidget {
  MessageFrame({Key? key}) : super(key: key);

  final _controller = Get.put(MessageFrameStateManager());
  final String podoImage = 'assets/images/logo.png';

  Widget getExpansionTile(Notice notice) {
    IconData icon = FontAwesomeIcons.bullhorn;
    switch (notice.tag) {
      case MyStrings.news:
        icon = FontAwesomeIcons.bullhorn;
        break;

      case MyStrings.imageQuiz:
        icon = FontAwesomeIcons.image;
        break;

      case MyStrings.audioQuiz:
        icon = FontAwesomeIcons.headphones;
        break;

      case MyStrings.liveLesson:
        icon = FontAwesomeIcons.video;
        break;
    }

    return ExpansionTile(
      title: Row(
        children: [
          Icon(
            icon,
            color: MyColors.greenDark,
          ),
          const SizedBox(width: 20),
          MyWidget().getTextWidget(notice.title, 15, MyColors.greenDark),
        ],
      ),
      children: [
        notice.contents,
      ],
      collapsedIconColor: MyColors.greenDark,
      iconColor: MyColors.greenDark,
      collapsedBackgroundColor: MyColors.greenLight,
      backgroundColor: MyColors.greenLight,
      childrenPadding: const EdgeInsets.all(10),
    );
  }

  @override
  Widget build(BuildContext context) {
    _controller.init();
    return SafeArea(
      child: Scaffold(
        floatingActionButton: ExpandableFab(
          distance: 80,
          children: [
            ActionButton(
              onPressed: () {
                Get.bottomSheet(
                  getBottomSheet(MyStrings.tagCorrection),
                  isScrollControlled: true,
                );
              },
              icon: const Icon(Icons.message_rounded),
            ),
            ActionButton(
              onPressed: () {
                Get.bottomSheet(
                  getBottomSheet(MyStrings.tagQuestion),
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
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GetBuilder<MessageFrameStateManager>(
                    builder: (_controller) {
                      return SizedBox(
                        height: 100,
                        child: Swiper(
                          itemCount: _controller.noticeList.length,
                          itemBuilder: (context, index) {
                            return getExpansionTile(_controller.noticeList[index]);
                          },
                          pagination: const SwiperPagination(
                              builder: DotSwiperPaginationBuilder(
                            color: MyColors.grey,
                          )),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: MyWidget().getSearchWidget(
                      _controller.focusNode,
                      _controller.searchController,
                      MyStrings.messageSearchHint,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      CupertinoIcons.ticket, //todo: podo 아이콘으로 바꾸기
                      color: MyColors.purple,
                    ),
                  ),
                  MyWidget().getTextWidget(UserInfo().podo.toString(), 15, MyColors.purple, isBold: true),
                  const SizedBox(width: 10),
                ],
              ),
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: msgList.length,
              //     itemBuilder: (BuildContext context, int index) {
              //       bool isUserMsg = msgList[index].isUserMsg;
              //       String image = isUserMsg ? 'assets/images/course_hangul.png' : 'assets/images/logo.png';
              //       String tag = msgList[index].tag;
              //       String msg = msgList[index].msg;
              //       String date = msgList[index].date;
              //       return getMsgItem(isUserMsg, image, tag, msg, date);
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getBottomSheet(String tag) {
    List<TextFieldItem> textFieldItems = _controller.textFieldItems;
    textFieldItems.clear();

    if (tag == MyStrings.tagCorrection) {
      textFieldItems.add(TextFieldItem(MyStrings.correctionHint, false));
    } else {
      textFieldItems.add(TextFieldItem(MyStrings.questionHint, false));
    }
    int podoCount = 1;

    return StatefulBuilder(
      builder: (context, reRender) {
        List<Widget> textFieldWidgets = [];

        if (tag == MyStrings.tagCorrection) {
          for (int i = 0; i < textFieldItems.length; i++) {
            textFieldItems[i].setRemoveFunction(() {
              reRender(() {
                int removeIdx = textFieldItems.indexWhere((element) => element.key == textFieldItems[i].key);
                textFieldItems.removeAt(removeIdx);
                podoCount--;
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
                tag == MyStrings.tagCorrection
                    ? IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: MyColors.purple,
                        ),
                        onPressed: () {
                          if (UserInfo().podo == podoCount) {
                            UserInfo().isPremium
                                ? Get.defaultDialog(
                                    titlePadding: const EdgeInsets.all(20),
                                    contentPadding: const EdgeInsets.only(bottom: 10),
                                    title: MyStrings.coinAlertTitle,
                                    middleText: MyStrings.coinAlertSubTitlePremium,
                                    onConfirm: () {
                                      Get.back();
                                    },
                                    confirmTextColor: Colors.white,
                                    buttonColor: MyColors.purple,
                                  )
                                : Get.defaultDialog(
                                    titlePadding: const EdgeInsets.all(20),
                                    contentPadding: const EdgeInsets.all(15),
                                    title: MyStrings.coinAlertTitle,
                                    middleText: MyStrings.coinAlertSubTitleNoPremium,
                                    onConfirm: () {
                                      Get.back();
                                      Get.to(const Subscribe());
                                    },
                                    onCancel: () {},
                                    confirmTextColor: Colors.white,
                                    cancelTextColor: MyColors.purple,
                                    buttonColor: MyColors.purple,
                                  );
                          } else {
                            reRender(() {
                              if (textFieldItems.length <= 1) {
                                for (TextFieldItem item in textFieldItems) {
                                  item.hasRemoveBtn = true;
                                }
                              }
                              textFieldItems.add(TextFieldItem('', true));
                              podoCount++;
                            });
                          }
                        },
                      )
                    : const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child:
                      MyWidget().getRoundBtnWidget(true, MyStrings.send, MyColors.purple, Colors.white, () {
                    //todo: DB에 저장할 때 correction 과 question 경로를 다르게 할 것
                    List<String> requests = [];
                    for (TextFieldItem item in textFieldItems) {
                      requests.add(item.controller.text);
                    }
                  }, podoCount: podoCount),
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
      padding: const EdgeInsets.symmetric(vertical: 10),
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

//todo: 컨트롤러 dispose() 하기
class TextFieldItem extends GetxController {
  Key key = UniqueKey();
  late String hint;
  late bool hasRemoveBtn;
  VoidCallback? removeFunction;
  final TextEditingController controller = TextEditingController();

  TextFieldItem(this.hint, this.hasRemoveBtn);

  void setRemoveFunction(VoidCallback f) {
    removeFunction = f;
  }

  @override
  void onClose() {
    debugPrint('TextFieldItem Closed!');
    controller.dispose();
    super.onClose();
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
                      onPressed: removeFunction)
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }
}

class MessageFrameStateManager extends GetxController {
  late List<Message> msgList;
  late List<Notice> noticeList;
  late FocusNode focusNode;
  late TextEditingController searchController;
  late bool isPremiumUser;
  late int correctionCount;
  late List<TextFieldItem> textFieldItems;

  void init() {
    msgList = []; //todo: 최신 메시지부터 10개씩 나눠서 로딩하기
    noticeList = SampleNotice().getNotices(); //todo: DB에서 isOnBoard = true 가져오기
    focusNode = FocusNode();
    searchController = TextEditingController();
    isPremiumUser = UserInfo().isPremium;
    correctionCount = 1;
    textFieldItems = [];
    //msgList.add(Message(false, '', MyStrings.messageInfo, ''));
    //todo: 이후의 메시지는 DB에서 가져오기
    // msgList.add(Message(true, '#${MyStrings.correction}', MyStrings.lorem, '2021년 11월 29일'));
    // msgList.add(Message(false, '#${MyStrings.correction}', MyStrings.lorem, '2021년 11월 29일'));
  }

  void disposeMessageFrame() {
    focusNode.dispose();
    searchController.dispose();
    update();
  }
}

class SampleNotice {
  Notice sampleNews = Notice('news_000', 'Update deployed', Html(data: """
        <div>
          <ul>
            <li>It actually works</li>
            <li>It exists</li>
            <li>It doesn't cost much!</li>
          </ul>
        </div>
        """), true, 0);

  Notice sampleImageQuiz = Notice('imageQuiz_000', 'Image quiz', Html(data: """
        <div>
          <ul>
            <li>Look at the picture below and make a sentence.</li>
            <li>Teacher Danny will proofread your answer.</li>
          </ul>
          <img src='asset:assets/images/course_hangul.png' width='100' />
        </div>
        """), true, 1);

  Notice sampleAudioQuiz = Notice('audioQuiz_000', 'Audio quiz', Html(data: """
        <div>
          <ul>
            <li>Listen to the audio and write what you hear.</li>
          </ul>
          <audio controls src='asset:assets/audio/sample.mp3'></audio>
        </div>
        """), true, 2);

  Notice sampleLiveLesson = Notice('liveLesson_000', 'Free Live Lesson', Html(data: """
        <div>
          <ul>
            <li>Status : available</li>
            <li>Time : 25th June 2022, 7:00PM </li>
            <li>Place : Zoom</li>
            <li>Subject : Reading Hangul</li>
            <li>Level : Beginner</li>
            <li>Limit : 10 students</li>
          </ul>
          <p style="color:red;">* Lesson will be recorded and can be released on the podo YouTube channel</p>
          <audio controls src='asset:assets/audio/sample.mp3'></audio>
        </div>
        """), true, 3);

  List<Notice> getNotices() {
    List<Notice> notices = [];
    notices.add(sampleNews);
    notices.add(sampleImageQuiz);
    notices.add(sampleAudioQuiz);
    notices.add(sampleLiveLesson);
    return notices;
  }
}
