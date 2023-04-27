import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/items/notice.dart';
import 'package:podo/screens/message/action_button.dart';
import 'package:podo/screens/message/expandable_fab.dart';
import 'package:podo/screens/subscribe/subscribe.dart';
import 'package:podo/items/user_info.dart';
import 'package:podo/screens/message/message_state_manager.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

enum ContentsKey { icon, widget }

class MessageFrame extends StatelessWidget {
  MessageFrame({Key? key}) : super(key: key);

  final MessageStateManager _controller = Get.put(MessageStateManager());
  final String podoImage = 'assets/images/logo.png';
  final Map<String, IconData> noticeIcons = {
    MyStrings.tagInfo: FontAwesomeIcons.bullhorn,
    MyStrings.tagQuiz: Icons.quiz_rounded,
    MyStrings.tagLiveLesson: FontAwesomeIcons.video,
  };

  @override
  Widget build(BuildContext context) {
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
              GetBuilder<MessageStateManager>(
                builder: (controller) {
                  Notice notice = controller.noticeList[controller.thisSwiperIndex];
                  List<Widget> contents = [];
                  contents.add(notice.contents);
                  contents.add(getContentAction(notice));

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ExpansionTile(
                      title: SizedBox(
                        height: 40,
                        child: Swiper(
                          onIndexChanged: (index) {
                            controller.thisSwiperIndex = index;
                            controller.update();
                          },
                          itemCount: controller.noticeList.length,
                          itemBuilder: (context, index) {
                            Notice notice = controller.noticeList[index];
                            return Row(
                              children: [
                                Icon(
                                  noticeIcons[notice.tag],
                                  color: MyColors.greenDark,
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Marquee(
                                    text:
                                        '${notice.title} (Expiring 00:00:00 Left)                          ',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: MyColors.greenDark,
                                    ),
                                    startAfter: const Duration(seconds: 2),
                                    pauseAfterRound: const Duration(seconds: 2),
                                  ),
                                ),
                              ],
                            );
                          },
                          pagination: const SwiperPagination(
                              alignment: Alignment.bottomRight,
                              margin: EdgeInsets.only(top: 20),
                              builder: DotSwiperPaginationBuilder(
                                  activeSize: 6,
                                  size: 4,
                                  color: MyColors.grey,
                                  activeColor: MyColors.greenDark)),
                        ),
                      ),
                      collapsedIconColor: MyColors.greenDark,
                      iconColor: MyColors.greenDark,
                      collapsedBackgroundColor: MyColors.greenLight,
                      backgroundColor: MyColors.greenLight,
                      children: contents,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: MyWidget().getSearchWidget(
                      focusNode: _controller.focusNode,
                      controller: _controller.searchController,
                      hint: MyStrings.messageSearchHint,
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
                  MyWidget().getTextWidget(
                    text: UserInfo().podoCoin.toString(),
                    size: 15,
                    color: MyColors.purple,
                    isBold: true,
                  ),
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
    List<TextFieldItem> textFieldItems = [];

    if (tag == MyStrings.tagCorrection) {
      textFieldItems.add(TextFieldItem(hint: MyStrings.correctionHint, hasRemoveBtn: false));
    } else {
      textFieldItems.add(TextFieldItem(hint: MyStrings.questionHint, hasRemoveBtn: false));
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
                    MyWidget().getTextWidget(text: tag, size: 20, color: MyColors.purple),
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
                          if (UserInfo().podoCoin == podoCount) {
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
                              textFieldItems.add(TextFieldItem(hint: '', hasRemoveBtn: true));
                              podoCount++;
                            });
                          }
                        },
                      )
                    : const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: MyWidget().getRoundBtnWidget(
                    isRequest: true,
                    text: MyStrings.send,
                    bgColor: MyColors.purple,
                    fontColor: Colors.white,
                    f: () {
                      //todo: DB에 저장할 때 correction 과 question 경로를 다르게 할 것
                      List<String> requests = [];
                      for (TextFieldItem item in textFieldItems) {
                        requests.add(item.controller.text);
                      }
                    },
                    podoCount: podoCount,
                  ),
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
        MyWidget().getCircleImageWidget(
          image: image,
          size: 50,
        ),
        const SizedBox(width: 10),
        Expanded(child: msgContainer(isUserMsg, tag, msg, msgColor, date))
      ];
    } else {
      msgColor = MyColors.pink;
      widgets = [
        Expanded(child: msgContainer(isUserMsg, tag, msg, msgColor, date)),
        const SizedBox(width: 10),
        MyWidget().getCircleImageWidget(
          image: image,
          size: 50,
        ),
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
        if (isUserMsg)
          MyWidget().getTextWidget(
            text: tag,
            size: 13,
            color: MyColors.grey,
          ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: msgColor,
          ),
          child: MyWidget().getTextWidget(
            text: msg,
            size: 15,
            color: Colors.black,
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: MyWidget().getTextWidget(
            text: date,
            size: 13,
            color: MyColors.grey,
          ),
        ),
      ],
    );
  }

  Widget getContentAction(Notice notice) {
    Widget action;
    switch (notice.tag) {
      case MyStrings.tagQuiz:
        List<Widget> actionContents = [];
        for (int i = 0; i < notice.examples!.length; i++) {
          actionContents.add(getTextButton(i, notice.examples![i]));
        }
        actionContents.add(const SizedBox(height: 10));
        actionContents.add(MyWidget().getRoundBtnWidget(
          isRequest: false,
          text: MyStrings.checkAnswer,
          bgColor: _controller.checkedAnswer != 0 ? MyColors.greenDark : MyColors.grey,
          fontColor: _controller.checkedAnswer != 0 ? MyColors.greenLight : Colors.white,
          f: () {
            //todo: 정답체크
            if(_controller.checkedAnswer != 0) {

            }
          },
        ));
        actionContents.add(const SizedBox(height: 10));
        action = Column(
          children: actionContents,
        );
        break;

      case MyStrings.tagLiveLesson:
        action = Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: _controller.isLiveLessonChecked,
                  onChanged: (bool? b) {
                    _controller.isLiveLessonChecked = b!;
                    _controller.update();
                  },
                ),
                MyWidget().getTextWidget(text: MyStrings.iAgree, size: 15, color: MyColors.greenDark),
              ],
            ),
            const SizedBox(height: 10),
            MyWidget().getRoundBtnWidget(
              isRequest: false,
              text: MyStrings.makeReservation,
              bgColor: _controller.isLiveLessonChecked ? MyColors.greenDark : MyColors.grey,
              fontColor: _controller.isLiveLessonChecked ? MyColors.greenLight : Colors.white,
              f: () {
                //todo: 예약하기
              },
            ),
            const SizedBox(height: 10),
          ],
        );
        break;

      default:
        action = const SizedBox.shrink();
    }

    return action;
  }

  Widget getTextButton(int index, String text) {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            _controller.checkedAnswer = index + 1;
            _controller.update();
          },
          child: MyWidget().getTextWidget(
            text: text,
            size: 18,
            color: _controller.checkedAnswer == index + 1 ? MyColors.purple : Colors.black,
          ),
        ),
      ],
    );
  }
}

class TextFieldItem extends GetxController {
  Key key = UniqueKey();
  late String hint;
  late bool hasRemoveBtn;
  VoidCallback? removeFunction;
  final TextEditingController controller = TextEditingController();

  TextFieldItem({required this.hint, required this.hasRemoveBtn});

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
              Expanded(
                  child: MyWidget().getTextFieldWidget(hint: hint, fontSize: 15, controller: controller)),
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

class SampleNotice {
  Notice sampleNews = Notice(
    noticeId: '#info_000',
    title: 'Update deployed',
    contents: Html(data: """
        <div>
          <ul>
            <li>It actually works</li>
            <li>It exists</li>
            <li>It doesn't cost much!</li>
          </ul>
        </div>
        """),
    isOnBoard: true,
  );

  Notice sampleQuiz = Notice(
    noticeId: '#quiz_000',
    title: 'Let\'s solve a quiz!',
    contents: Html(data: """
        <div>
          <p>Which of the following statements is correct?</p>
        </div>
        """),
    isOnBoard: true,
    examples: ['ㄱ. answer1', 'ㄴ. answer2', 'ㄷ. answer3', 'ㄹ. answer4'],
    answer: 'ㄹ. answer4',
  );

  Notice sampleLiveLesson = Notice(
    noticeId: '#liveLesson_000',
    title: 'Free Live Lesson',
    contents: Html(data: """
        <div>
          <ul>
            <li>When : 25th June 2022, 7:00PM </li>
            <li>Where : Zoom</li>
            <li>What about : Reading Hangul</li>
            <li>For who : Beginner</li>
            <li>How many : 10 students</li>
          </ul>
          <p style="color:red;">* Lesson will be recorded and can be released on the podo YouTube channel</p>
        </div>
        """),
    isOnBoard: true,
  );

  List<Notice> getNotices() {
    List<Notice> notices = [];
    notices.add(sampleNews);
    notices.add(sampleQuiz);
    notices.add(sampleLiveLesson);
    return notices;
  }
}
