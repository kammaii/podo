import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/message/cloud_message.dart';
import 'package:podo/screens/message/cloud_message_controller.dart';
import 'package:podo/screens/message/cloud_reply.dart';
import 'package:podo/screens/profile/history.dart';
import 'package:podo/screens/profile/user.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class CloudMessageMain extends StatelessWidget {
  CloudMessageMain({Key? key}) : super(key: key);

  final KO = 'ko';
  final replyController = TextEditingController();
  bool hasReplied = Get.find<CloudMessageController>().hasReplied.value;

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
    String? reply;
    if(hasReplied) {
      for(dynamic snapshot in User().cloudMessageHistory) {
        History history = History.fromJson(snapshot);
        if(history.itemId == CloudMessage().id) {
          reply = history.content;
          break;
        }
      }
    }
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
            SingleChildScrollView(
              child: Padding(
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
                                      'div': Style(width: 200, height: 200, textAlign: TextAlign.center),
                                      'p': Style(
                                          fontFamily: 'EnglishFont',
                                          fontSize: const FontSize(18),
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
                        MyWidget().getTextWidget(text: MyStrings.bestReplies, color: MyColors.purple, size: 20),
                      ],
                    ),
                  ],
                ),
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
                                  Get.dialog(AlertDialog(
                                    title: MyWidget().getTextWidget(text: MyStrings.sendReply, size: 18),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          child:
                                              MyWidget().getTextWidget(text: MyStrings.no, color: MyColors.grey)),
                                      TextButton(
                                          onPressed: () {
                                            Get.back();
                                            CloudReply reply = CloudReply(replyController.text);
                                            Database().sendReplyBatch(
                                                reply: reply,
                                                thenFn: (value) {
                                                  print('Cloud reply completed');
                                                  Get.back();
                                                  Get.find<CloudMessageController>().setHasReplied(true);
                                                });
                                          },
                                          child: MyWidget()
                                              .getTextWidget(text: MyStrings.yes, color: MyColors.purple)),
                                    ],
                                  ));
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
          ],
        ),
      ),
    );
  }
}
