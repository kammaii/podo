import 'dart:async';
import 'dart:typed_data';
import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:podo/common/database.dart';
import 'package:podo/common/flashcard_icon.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/message/podo_message.dart';
import 'package:podo/screens/message/podo_message_controller.dart';
import 'package:podo/screens/message/podo_message_reply.dart';
import 'package:podo/common/history.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PodoMessageMain extends StatefulWidget {
  PodoMessageMain({Key? key}) : super(key: key);

  @override
  State<PodoMessageMain> createState() => _PodoMessageMainState();
}

class _PodoMessageMainState extends State<PodoMessageMain> {
  final KO = 'ko';
  final replyController = TextEditingController();
  bool isReplyAvailable = true;
  late String replyHint;
  final controller = Get.find<PodoMessageController>();
  bool isBasicUser = User().status == 1;
  just_audio.AudioPlayer? player;
  late ResponsiveSize rs;
  bool isLoaded = false;
  late Timer timer;
  StreamController<String> streamController = StreamController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        isLoaded = true;
        if (isBasicUser) {
          MyWidget().showDialog(context, rs, content: tr('wantReplyPodo'), yesFn: () {
            Get.toNamed(MyStrings.routePremiumMain);
          }, hasPremiumTag: true, hasNoBtn: false, yesText: tr('explorePremium'));
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    streamController.close();
    super.dispose();
  }

  Stream<String> getTimeLeftStream(DateTime dateEnd) {
    Duration calTimeLeft() {
      DateTime now = DateTime.now();
      Duration leftTime = PodoMessage().dateEnd!.difference(now);
      return leftTime.isNegative ? Duration.zero : leftTime;
    }

    void updateText() {
      if (!mounted) {
        return;
      }
      Duration leftTime = calTimeLeft();
      String day = leftTime.inDays != 0 ? '${leftTime.inDays.toString().padLeft(2, '0')} 일' : '';
      String hour = '${(leftTime.inHours % 24).toString().padLeft(2, '0')} 시간';
      String min = '${(leftTime.inMinutes % 60).toString().padLeft(2, '0')} 분';
      String sec = '${(leftTime.inSeconds % 60).toString().padLeft(2, '0')} 초';
      streamController.add('$day $hour $min $sec');

      if (leftTime == Duration.zero) {
        timer.cancel();
        streamController.close();
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

    streamController = StreamController<String>(onListen: () {
      updateText();
      startTimer();
    }, onCancel: () {
      timer.cancel();
    });

    return streamController.stream;
  }

  Widget getAudioPlayer(String url) {
    player = just_audio.AudioPlayer();
    player!.setUrl(url);
    player!.playerStateStream.listen((event) {
      if (event.processingState == just_audio.ProcessingState.completed) {
        player!.seek(Duration.zero);
        player!.pause();
      }
    });
    return Row(
      children: [
        StreamBuilder<just_audio.PlayerState>(
          stream: player!.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final isPlaying = playerState?.playing ?? false;
            return IconButton(
              icon: Icon(isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_arrow_solid,
                  size: rs.getSize(20)),
              color: MyColors.purple,
              onPressed: () {
                isPlaying ? player!.pause() : player!.play();
              },
            );
          },
        ),
        StreamBuilder<Duration?>(
          stream: player!.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final duration = player!.duration ?? Duration.zero;
            return Expanded(
              child: Slider(
                value: position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble(),
                onChanged: (value) {
                  player!.seek(Duration(milliseconds: value.toInt()));
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
        flags: YoutubePlayerFlags(autoPlay: isBasicUser ? false : true),
      ),
      actionsPadding: EdgeInsets.all(rs.getSize(10)),
      bottomActions: [
        CurrentPosition(),
        SizedBox(width: rs.getSize(10)),
        ProgressBar(isExpanded: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    rs = ResponsiveSize(context);
    String? reply;
    if (controller.hasReplied) {
      History history = LocalStorage().histories.firstWhere((history) => history.itemId == PodoMessage().id);
      reply = history.content;
      isReplyAvailable = false;
      replyHint = reply!;
    } else if (controller.hasExpired) {
      replyHint = tr('expired');
      isReplyAvailable = false;
    } else {
      replyHint = tr('replyPodo');
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Theme(
          data: Theme.of(context).copyWith(highlightColor: MyColors.navyLight),
          child: AppBar(
            backgroundColor: Theme.of(context).cardColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                if (player != null) {
                  player!.dispose();
                }
                Get.back();
              },
              icon: Icon(Icons.arrow_back_ios_rounded, size: rs.getSize(20)),
              color: Theme.of(context).primaryColor,
            ),
            title: MyWidget().getTextWidget(
              rs,
              text: PodoMessage().title![KO],
              color: Theme.of(context).primaryColor,
              isKorean: true,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Get.dialog(AlertDialog(
                    backgroundColor: Theme.of(context).cardColor,
                    title: MyWidget().getTextWidget(rs,
                        text: tr('howToUse'), size: 18, color: Theme.of(context).secondaryHeaderColor),
                    content: MyWidget()
                        .getTextWidget(rs, text: tr('replyDetail'), color: Theme.of(context).disabledColor),
                  ));
                },
                icon: Icon(CupertinoIcons.info_circle,
                    color: Theme.of(context).primaryColor, size: rs.getSize(23, bigger: 1.2)),
              )
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: rs.getSize(10), right: rs.getSize(10), top: rs.getSize(20), bottom: rs.getSize(100)),
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
                                textStyle: TextStyle(
                                    fontFamily: 'EnglishFont',
                                    fontSize: rs.getSize(18),
                                    height: 1.5,
                                    color: Theme.of(context).secondaryHeaderColor),
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
                                    return Image.memory(bytes, width: rs.getSize(200), height: rs.getSize(200));
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
                      Icon(Icons.thumb_up_off_alt, color: Theme.of(context).primaryColor, size: rs.getSize(20)),
                      SizedBox(width: rs.getSize(10)),
                      MyWidget().getTextWidget(rs,
                          text: tr('bestReplies'), color: Theme.of(context).primaryColor, size: 20),
                    ],
                  ),
                  SizedBox(height: rs.getSize(20)),
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
                              controller.hasFlashcard.value = {};

                              for (dynamic snapshot in snapshot.data) {
                                replies.add(PodoMessageReply.fromJson(snapshot.data() as Map<String, dynamic>));
                              }
                              return ListView.builder(
                                itemCount: replies.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  PodoMessageReply reply = replies[index];
                                  controller.hasFlashcard[reply.id] =
                                      LocalStorage().hasFlashcard(itemId: reply.id);
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: rs.getSize(5)),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            color: Theme.of(context).cardColor,
                                            child: Padding(
                                              padding: EdgeInsets.all(rs.getSize(10)),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 6,
                                                        height: 6,
                                                        decoration: BoxDecoration(
                                                          color: index % 2 == 0
                                                              ? Theme.of(context).primaryColorLight
                                                              : Theme.of(context).shadowColor,
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ),
                                                      SizedBox(width: rs.getSize(10)),
                                                      Expanded(
                                                          child: MyWidget().getTextWidget(rs,
                                                              text: reply.reply,
                                                              isKorean: true,
                                                              size: 16,
                                                              height: 1.5,
                                                              color: Theme.of(context).secondaryHeaderColor)),
                                                      SizedBox(width: rs.getSize(10)),
                                                      isLoaded
                                                          ? Obx(() => FlashcardIcon().getIconButton(context, rs,
                                                              controller: controller,
                                                              itemId: reply.id,
                                                              front: reply.reply))
                                                          : const SizedBox.shrink()
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        reply.isCorrected
                                                            ? MyWidget().getRoundedContainer(
                                                                widget: const Icon(Icons.auto_fix_high_rounded,
                                                                    color: MyColors.greenDark, size: 15),
                                                                bgColor: MyColors.greenLight,
                                                                radius: 10,
                                                                padding: const EdgeInsets.symmetric(
                                                                    vertical: 3, horizontal: 5))
                                                            : MyWidget().getRoundedContainer(
                                                                widget: const Icon(Icons.thumb_up_alt_rounded,
                                                                    color: MyColors.mustard, size: 15),
                                                                bgColor: MyColors.mustardLight,
                                                                radius: 10,
                                                                padding: const EdgeInsets.symmetric(
                                                                    vertical: 3, horizontal: 5)),
                                                        MyWidget().getTextWidget(
                                                          rs,
                                                          text: reply.userName.isEmpty
                                                              ? tr('unNamed')
                                                              : reply.userName,
                                                          color: Theme.of(context).disabledColor,
                                                        ),
                                                      ],
                                                    ),
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
                          padding: EdgeInsets.symmetric(vertical: rs.getSize(100)),
                          child: MyWidget().getTextWidget(rs,
                              text: tr('noBestReply'),
                              color: Theme.of(context).primaryColorDark,
                              isTextAlignCenter: true),
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
                  padding: EdgeInsets.only(bottom: rs.getSize(5), right: rs.getSize(15)),
                  child: StreamBuilder<String>(
                    stream: getTimeLeftStream(PodoMessage().dateEnd!),
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return MyWidget()
                            .getTextWidget(rs, text: snapshot.data!, color: Theme.of(context).primaryColor);
                      } else {
                        return Text(tr('expired'));
                      }
                    },
                  ),
                ),
                Container(
                  color: Theme.of(context).primaryColorLight,
                  height: rs.getSize(70),
                  child: Padding(
                    padding: EdgeInsets.only(left: rs.getSize(10)),
                    child: Row(
                      children: [
                        Expanded(
                          child: MyWidget().getTextFieldWidget(
                            context,
                            rs,
                            hint: replyHint,
                            controller: replyController,
                            enabled: isReplyAvailable,
                          ),
                        ),
                        SizedBox(width: rs.getSize(20)),
                        IgnorePointer(
                          ignoring: !isReplyAvailable,
                          child: IconButton(
                            onPressed: () {
                              MyWidget().showDialog(
                                context,
                                rs,
                                content: tr('sendReply'),
                                yesFn: () async {
                                  await FirebaseAnalytics.instance.logEvent(name: 'fcm_reply');
                                  PodoMessageReply reply = PodoMessageReply(replyController.text);
                                  await Database().setDoc(
                                      collection: 'PodoMessages/${PodoMessage().id}/Replies',
                                      doc: reply,
                                      thenFn: (value) {
                                        print('Podo message reply completed');
                                      });
                                  await History().addHistory(
                                      itemIndex: 2, itemId: PodoMessage().id!, content: replyController.text);
                                  Get.find<PodoMessageController>().setPodoMsgBtn();
                                  setState(() {});
                                },
                              );
                            },
                            icon: Icon(Icons.send,
                                color: !isReplyAvailable
                                    ? Theme.of(context).disabledColor
                                    : Theme.of(context).primaryColor,
                                size: rs.getSize(20)),
                          ),
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
    );
  }
}
