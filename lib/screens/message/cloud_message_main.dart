import 'dart:async';
import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/message/cloud_message.dart';
import 'package:podo/screens/message/cloud_message_controller.dart';
import 'package:podo/screens/message/cloud_reply.dart';
import 'package:podo/common/history.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class CloudMessageMain extends StatelessWidget {
  CloudMessageMain({Key? key}) : super(key: key);

  final KO = 'ko';
  final replyController = TextEditingController();
  late bool hasReplied;
  final controller = Get.find<CloudMessageController>();
  bool isBasicUser = User().status == 1;

  Stream<String> getTimeLeftStream(DateTime dateEnd) {
    StreamController<String> controller = StreamController();
    late Timer timer;

    Duration calTimeLeft() {
      DateTime now = DateTime.now();
      Duration leftTime = CloudMessage().dateEnd!.difference(now);
      return leftTime.isNegative ? Duration.zero : leftTime;
    }

    void updateText() {
      Duration leftTime = calTimeLeft();
      String day = leftTime.inDays != 0 ? '${leftTime.inDays.toString().padLeft(2, '0')} 일' : '';
      String hour = '${(leftTime.inHours % 24).toString().padLeft(2, '0')} 시간';
      String min = '${(leftTime.inMinutes % 60).toString().padLeft(2, '0')} 분';
      String sec = '${(leftTime.inSeconds % 60).toString().padLeft(2, '0')} 초';
      controller.add('$day $hour $min $sec');

      if (leftTime == Duration.zero) {
        timer.cancel();
        controller.close();
      }
    }

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      updateText();
    });

    void startTimer() {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        updateText();
      });
    }

    controller = StreamController<String>(onListen: () {
      updateText();
      startTimer();
    }, onCancel: () {
      timer.cancel();
    });

    return controller.stream;
  }

  @override
  Widget build(BuildContext context) {
    hasReplied = controller.hasReplied.value;
    String? reply;
    if (hasReplied) {
      History history = LocalStorage().histories.firstWhere((history) => history.itemId == CloudMessage().id);
      reply = history.content;
    }
    Query query = FirebaseFirestore.instance
        .collection('CloudMessages/${CloudMessage().id}/Replies')
        .where('isSelected', isEqualTo: true)
        .orderBy('date', descending: true);

    isBasicUser ?
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      MyWidget().showDialog(
          content: MyStrings.wantReplyPodo,
          yesFn: () {
            Get.toNamed(MyStrings.routePremiumMain);
          });
    }) : null;

    return Scaffold(
      appBar: MyWidget().getAppbar(title: CloudMessage().title![KO], isKorean: true, actions: [
        IconButton(
          onPressed: () {
            Get.dialog(AlertDialog(
              title: MyWidget().getTextWidget(text: MyStrings.howToUse, size: 18),
              content: MyWidget().getTextWidget(text: MyStrings.replyDetail, color: MyColors.grey),
            ));
          },
          icon: const Icon(Icons.info, color: MyColors.purple),
        )
      ]),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                children: [
                  CloudMessage().content != null
                      ? Column(
                          children: [
                            Column(
                              children: [
                                Html(
                                  data: CloudMessage().content,
                                  style: {
                                    'div': Style(width: Width(200), height: Height(200), textAlign: TextAlign.center),
                                    'p': Style(
                                        fontFamily: 'EnglishFont',
                                        fontSize: FontSize(18),
                                        lineHeight: LineHeight.number(1.5)),
                                  },
                                ),
                                const Divider(),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.thumb_up_off_alt, color: MyColors.purple),
                      const SizedBox(width: 10),
                      MyWidget().getTextWidget(text: MyStrings.bestReplies, color: MyColors.purple, size: 20),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder(
                      future: Database().getDocs(query: query),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                          List<CloudReply> replies = [];
                          for (dynamic snapshot in snapshot.data) {
                            replies.add(CloudReply.fromJson(snapshot.data() as Map<String, dynamic>));
                          }
                          controller.hasFlashcard.value = List.generate(replies.length, (index) => false);
                          if (replies.isEmpty) {
                            return Center(
                                child: MyWidget().getTextWidget(
                                    text: MyStrings.noBestReply,
                                    color: MyColors.purple,
                                    size: 20,
                                    isTextAlignCenter: true));
                          } else {
                            return ListView.builder(
                              itemCount: replies.length,
                              itemBuilder: (BuildContext context, int index) {
                                CloudReply reply = replies[index];
                                controller.hasFlashcard[index] = LocalStorage().hasFlashcard(itemId: reply.id);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 6,
                                                      height: 6,
                                                      decoration: BoxDecoration(
                                                        color: index % 2 == 0 ? MyColors.navyLight : MyColors.pink,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                        child: MyWidget().getTextWidget(
                                                            text: reply.reply,
                                                            isKorean: true,
                                                            size: 16,
                                                            height: 1.5)),
                                                    const SizedBox(width: 10),
                                                    Obx(() => IconButton(
                                                        onPressed: () {
                                                          if (controller.hasFlashcard[index]) {
                                                            FlashCard().removeFlashcard(itemId: reply.id);
                                                            controller.hasFlashcard[index] = false;
                                                          } else {
                                                            FlashCard().addFlashcard(
                                                                itemId: reply.id,
                                                                front: reply.reply,
                                                                fn: () {
                                                                  controller.hasFlashcard[index] = true;
                                                                });
                                                          }
                                                        },
                                                        icon: Icon(
                                                          controller.hasFlashcard[index]
                                                              ? CupertinoIcons.heart_fill
                                                              : CupertinoIcons.heart,
                                                          color: MyColors.purple,
                                                        ))),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 10, top: 5),
                                                      child: MyWidget().getTextWidget(
                                                          text: reply.userName.isEmpty
                                                              ? MyStrings.unNamed
                                                              : reply.userName,
                                                          color: MyColors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        } else if (snapshot.hasError) {
                          return Text('에러: ${snapshot.error}');
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5, right: 15),
                    child: StreamBuilder<String>(
                      stream: getTimeLeftStream(CloudMessage().dateEnd!),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          return MyWidget().getTextWidget(text: snapshot.data!, color: MyColors.purple);
                        } else {
                          return const Text(MyStrings.expired);
                        }
                      },
                    ),
                  ),
                  Container(
                    color: MyColors.navyLight,
                    height: 70,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: MyWidget().getTextFieldWidget(
                              hint: hasReplied ? reply! : MyStrings.replyPodo,
                              controller: replyController,
                              enabled: !hasReplied,
                            ),
                          ),
                          const SizedBox(width: 20),
                          IgnorePointer(
                            ignoring: hasReplied,
                            child: IconButton(
                                onPressed: () {
                                  MyWidget().showDialog(
                                      content: MyStrings.sendReply,
                                      yesFn: () async {
                                        CloudReply reply = CloudReply(replyController.text);
                                        await Database().setDoc(
                                            collection: 'CloudMessages/${CloudMessage().id}/Replies',
                                            doc: reply,
                                            thenFn: (value) {
                                              print('Cloud reply completed');
                                              Get.back();
                                              Get.find<CloudMessageController>().setHasReplied(true);
                                            });
                                        History().addHistory(
                                            item: 'cloudMessage',
                                            itemId: CloudMessage().id!,
                                            content: replyController.text);
                                      });
                                },
                                icon: Icon(Icons.send, color: hasReplied ? MyColors.grey : MyColors.purple)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            isBasicUser
                ? const Positioned.fill(
                    child: Blur(
                      blur: 2.3,
                      child: SizedBox.shrink(),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
