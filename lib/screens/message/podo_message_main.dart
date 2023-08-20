import 'dart:async';
import 'dart:typed_data';
import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/message/podo_message.dart';
import 'package:podo/screens/message/podo_message_controller.dart';
import 'package:podo/screens/message/podo_message_reply.dart';
import 'package:podo/common/history.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PodoMessageMain extends StatelessWidget {
  PodoMessageMain({Key? key}) : super(key: key);

  final KO = 'ko';
  final replyController = TextEditingController();
  late bool hasReplied;
  final controller = Get.find<PodoMessageController>();
  bool isBasicUser = User().status == 1;

  Stream<String> getTimeLeftStream(DateTime dateEnd) {
    StreamController<String> controller = StreamController();
    late Timer timer;

    Duration calTimeLeft() {
      DateTime now = DateTime.now();
      Duration leftTime = PodoMessage().dateEnd!.difference(now);
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

  Widget getAudioPlayer(String url) {
    just_audio.AudioPlayer player = just_audio.AudioPlayer();
    player.setUrl(url);
    player.playerStateStream.listen((event) {
      if (event.processingState == just_audio.ProcessingState.completed) {
        player.seek(Duration.zero);
        player.pause();
      }
    });
    return Row(
      children: [
        StreamBuilder<just_audio.PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final isPlaying = playerState?.playing ?? false;
            return IconButton(
              icon: Icon(isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_arrow_solid),
              color: MyColors.purple,
              onPressed: () {
                isPlaying ? player.pause() : player.play();
              },
            );
          },
        ),
        StreamBuilder<Duration?>(
          stream: player.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final duration = player.duration ?? Duration.zero;
            return Expanded(
              child: Slider(
                value: position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble(),
                onChanged: (value) {
                  player.seek(Duration(milliseconds: value.toInt()));
                },
                max: duration.inMilliseconds.toDouble(),
                activeColor: MyColors.purple,
                inactiveColor: MyColors.purple.withOpacity(0.3),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget getVideoPlayer(String url) {
    return YoutubePlayer(
      controller: YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(url)!,
        flags: const YoutubePlayerFlags(),
      ),
      actionsPadding: const EdgeInsets.all(10),
      bottomActions: [
        CurrentPosition(),
        const SizedBox(width: 10),
        ProgressBar(isExpanded: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    hasReplied = controller.hasReplied.value;
    String? reply;
    if (hasReplied) {
      History history = LocalStorage().histories.firstWhere((history) => history.itemId == PodoMessage().id);
      reply = history.content;
    }

    isBasicUser
        ? WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            MyWidget().showDialog(
                content: tr('wantReplyPodo'),
                yesFn: () {
                  Get.toNamed(MyStrings.routePremiumMain);
                });
          })
        : null;

    return Scaffold(
      appBar: MyWidget().getAppbar(title: PodoMessage().title![KO], isKorean: true, actions: [
        IconButton(
          onPressed: () {
            Get.dialog(AlertDialog(
              title: MyWidget().getTextWidget(text: tr('howToUse'), size: 18),
              content: MyWidget().getTextWidget(text: tr('replyDetail'), color: MyColors.grey),
            ));
          },
          icon: const Icon(Icons.info, color: MyColors.purple),
        )
      ]),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 100),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    PodoMessage().content != null
                        ? Column(
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 3000),
                                child: HtmlWidget(
                                  PodoMessage().content!,
                                  textStyle: const TextStyle(
                                    fontFamily: 'EnglishFont',
                                    fontSize: 18,
                                    height: 1.5,
                                  ),
                                  customWidgetBuilder: (element) {
                                    if (element.localName == 'audio') {
                                      final String audioSrc = element.attributes['src']!;
                                      return getAudioPlayer(audioSrc);
                                    } else if (element.localName == 'video') {
                                      final String videoSrc = element.attributes['src']!;
                                      return getVideoPlayer(videoSrc);
                                    } else if (element.localName == 'img') {
                                      final String imageSrc = element.attributes['src']!;
                                      final UriData imageData = UriData.fromUri(Uri.parse(imageSrc));
                                      final Uint8List bytes = imageData.contentAsBytes();
                                      return Image.memory(bytes, width: 200, height: 200);
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const Divider(),
                            ],
                          )
                        : const SizedBox.shrink(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.thumb_up_off_alt, color: MyColors.purple),
                        const SizedBox(width: 10),
                        MyWidget().getTextWidget(text: tr('bestReplies'), color: MyColors.purple, size: 20),
                      ],
                    ),
                    const SizedBox(height: 20),
                    PodoMessage().hasBestReply
                        ? FutureBuilder(
                            future: Database().getDocs(
                                query: FirebaseFirestore.instance
                                    .collection('PodoMessages/${PodoMessage().id}/Replies')
                                    .where('isSelected', isEqualTo: true)
                                    .orderBy('date', descending: true)),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                                List<PodoMessageReply> replies = [];
                                for (dynamic snapshot in snapshot.data) {
                                  replies.add(PodoMessageReply.fromJson(snapshot.data() as Map<String, dynamic>));
                                }
                                controller.hasFlashcard.value = List.generate(replies.length, (index) => false);
                                return ListView.builder(
                                  itemCount: replies.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext context, int index) {
                                    PodoMessageReply reply = replies[index];
                                    controller.hasFlashcard[index] = LocalStorage().hasFlashcard(itemId: reply.id);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
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
                                                            color: index % 2 == 0
                                                                ? MyColors.navyLight
                                                                : MyColors.pink,
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
                                                                  ? tr('unNamed')
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
                              } else if (snapshot.hasError) {
                                return Text('에러: ${snapshot.error}');
                              } else {
                                return const Center(child: CircularProgressIndicator());
                              }
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 100),
                            child: MyWidget().getTextWidget(
                                text: tr('noBestReply'), color: MyColors.navy, isTextAlignCenter: true),
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
                      stream: getTimeLeftStream(PodoMessage().dateEnd!),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          return MyWidget().getTextWidget(text: snapshot.data!, color: MyColors.purple);
                        } else {
                          return Text(tr('expired'));
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
                              hint: hasReplied ? reply! : tr('replyPodo'),
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
                                      content: tr('sendReply'),
                                      yesFn: () async {
                                        //todo: await FirebaseAnalytics.instance.logEvent(name: 'fcm_reply');
                                        PodoMessageReply reply = PodoMessageReply(replyController.text);
                                        await Database().setDoc(
                                            collection: 'PodoMessages/${PodoMessage().id}/Replies',
                                            doc: reply,
                                            thenFn: (value) {
                                              print('Podo message reply completed');
                                              Get.back();
                                              Get.find<PodoMessageController>().setHasReplied(true);
                                            });
                                        History().addHistory(
                                            item: 'podoMessage',
                                            itemId: PodoMessage().id!,
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
