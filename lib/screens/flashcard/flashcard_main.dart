import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podo/common/favorite_icon.dart';
import 'package:podo/common/my_tutorial.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/common/play_stop_icon.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/flashcard/flashcard_controller.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class FlashCardMain extends StatefulWidget {
  const FlashCardMain({Key? key}) : super(key: key);

  @override
  _FlashCardMainState createState() => _FlashCardMainState();
}

class _FlashCardMainState extends State<FlashCardMain> with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController searchController = TextEditingController();
  List<FlashCard> cardsSearch = [];
  final controller = Get.put(FlashCardController());
  final duration = const Duration(milliseconds: 200);
  String searchText = '';
  Map<String, PlayStopIcon> playStopIcons = {};
  late int cardsLength;
  DocumentSnapshot? lastSnapshot;
  bool isBasicUser = User().status == 1;
  late ResponsiveSize rs;
  int limit = 20;

  MyTutorial? myTutorial;
  GlobalKey? keyCard;
  GlobalKey? keyReview;

  @override
  void initState() {
    super.initState();
    controller.init();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    searchController.dispose();
  }

  Widget animationWidget(Widget child) {
    return AnimatedContainer(
      width: controller.isLongClicked ? 30 : 0,
      duration: duration,
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: controller.isLongClicked ? 1.0 : 0.0,
        duration: duration,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    rs = ResponsiveSize(context);

    // 앱 실행 시 플래시 카드가 empty 면 실행 안 됨.
    myTutorial = MyTutorial();
    bool isTutorialEnabled = myTutorial!.isTutorialEnabled(myTutorial!.TUTORIAL_FLASHCARD_MAIN) && controller.cards.isNotEmpty;
    if(isTutorialEnabled) {
      keyCard = keyCard ?? GlobalKey();
      keyReview = GlobalKey();
      List<TargetFocus> targets = [
        myTutorial!.tutorialItem(id: "T1", keyTarget: keyCard, content: tr('tutorial_flashcard_frame_1')),
        myTutorial!.tutorialItem(id: "T2", keyTarget: keyCard, content: tr('tutorial_flashcard_frame_2')),
        myTutorial!.tutorialItem(id: "T3", keyTarget: keyReview, content: tr('tutorial_flashcard_frame_3'), isAlignBottom: false),
      ];
      myTutorial!.addTargetsAndRunTutorial(context, targets);

    } else {
      myTutorial = null;
    }

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                MyWidget().getSearchWidget(context, rs,
                    focusNode: _focusNode, controller: searchController, hint: tr('search'), onChanged: (text) {
                  searchText = searchController.text;
                  controller.update();
                }),
                SizedBox(height: rs.getSize(20)),
                Expanded(
                  child: GetBuilder<FlashCardController>(
                    builder: (_) {
                      for (FlashCard card in controller.cards) {
                        if (card.audio != null) {
                          playStopIcons[card.id] = PlayStopIcon(rs, this);
                        }
                      }
                      cardsLength = controller.cards.length;

                      if (searchText.isNotEmpty) {
                        cardsSearch = [];
                        for (FlashCard card in controller.cards) {
                          if (searchText.isNotEmpty &&
                              (card.front.toLowerCase().contains(searchText) ||
                                  card.back.toLowerCase().contains(searchText))) {
                            cardsSearch.add(card);
                          }
                        }
                        cardsLength = cardsSearch.length;
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                animationWidget(
                                    MyWidget().getCheckBox(rs, value: controller.isCheckedAll, onChanged: (value) {
                                  controller.isCheckedAllClicked(value!);
                                })),
                                Row(
                                  children: [
                                    animationWidget(IconButton(
                                        onPressed: () {
                                          MyWidget().showDialog(context, rs, content: tr('wantRemoveFlashcard'), yesFn: () {
                                            List<String> ids = [];
                                            for (int i = 0; i < controller.isChecked.length; i++) {
                                              controller.isChecked[i] ? ids.add(controller.cards[i].id) : null;
                                            }
                                            FlashCard().removeFlashcards(ids: ids);
                                          });
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: MyColors.red,
                                          size: rs.getSize(20),
                                        ))),
                                    SizedBox(width: rs.getSize(20)),
                                    InkWell(
                                      onTap: isBasicUser
                                          ? () {
                                              Get.toNamed(MyStrings.routePremiumMain);
                                            }
                                          : null,
                                      child: Row(
                                        children: [
                                          MyWidget().getTextWidget(rs,
                                              text: '$cardsLength ', color: Theme.of(context).secondaryHeaderColor),
                                          isBasicUser
                                              ? MyWidget().getTextWidget(
                                                  rs,
                                                  text: '/ ${limit.toString()} ',
                                                  color: Theme.of(context).focusColor,
                                                  isBold: true,
                                                )
                                              : const SizedBox.shrink(),
                                          MyWidget().getTextWidget(rs,
                                              text: tr('cards'), color: Theme.of(context).secondaryHeaderColor),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Expanded(
                              child: cardsLength <= 0
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        FavoriteIcon().getIcon(context, rs),
                                        SizedBox(height: rs.getSize(10)),
                                        MyWidget().getTextWidget(rs,
                                            text: tr('noFlashCards'), isTextAlignCenter: true, size: 18, color: Theme.of(context).secondaryHeaderColor),
                                        SizedBox(height: rs.getSize(50)),
                                      ],
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        _focusNode.unfocus();
                                      },
                                      onLongPress: () {
                                        controller.isLongClicked = !controller.isLongClicked;
                                        controller.update();
                                      },
                                      child: ListView.builder(
                                        padding: EdgeInsets.only(top: rs.getSize(10), bottom: rs.getSize(80)),
                                        itemCount: cardsLength,
                                        itemBuilder: (BuildContext context, int index) {
                                          bool hasKey = isTutorialEnabled && index == 0;
                                          return Padding(
                                            padding: EdgeInsets.only(bottom: rs.getSize(8)),
                                            child: getFlashCardItem(index, hasKey),
                                          );
                                        },
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rs.getSize(20), vertical: rs.getSize(30)),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                    child: GetBuilder<FlashCardController>(
                      builder: (_) {
                        return MyWidget().getRoundBtnWidget(
                          key: keyReview,
                          rs,
                          text: tr('review'),
                          bgColor: controller.cards.isNotEmpty ? Theme.of(context).canvasColor : Theme.of(context).disabledColor,
                          f: onReviewBtn,
                          hasNullFunction: true,
                          fontColor: Theme.of(context).cardColor
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Function? onReviewBtn() {
    if (controller.cards.isNotEmpty) {
      return () {
        Get.toNamed(MyStrings.routeFlashcardReview);
      };
    } else {
      return null;
    }
  }

  void setPlayStopIcon(int index, {required bool isForward}) {
    FlashCard card = controller.cards[index];
    if (isForward) {
      playStopIcons[card.id]!.clickIcon(isForward: true);
      card.isPlay = true;
    } else {
      playStopIcons[card.id]!.clickIcon(isForward: false);
      card.isPlay = false;
    }
  }

  Widget getFlashCardItem(int index, bool hasKey) {
    FlashCard card;
    searchText.isEmpty ? card = controller.cards[index] : card = cardsSearch[index];
    String front = card.front;
    String back = card.back;
    bool hasKey = index == 0;

    return Row(
      children: [
        animationWidget(MyWidget().getCheckBox(rs, value: controller.isChecked[index], onChanged: (value) {
          controller.isChecked[index] = value!;
          controller.update();
        })),
        SizedBox(width: rs.getSize(10)),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _focusNode.unfocus();
              Get.toNamed(MyStrings.routeFlashcardEdit, arguments: card);
            },
            child: Row(
              children: [
                Expanded(
                    child: Text(key: hasKey ? keyCard : null, front,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: rs.getSize(15, bigger: 1.2), color: Theme.of(context).secondaryHeaderColor))),
                SizedBox(
                    width: rs.getSize(20),
                    height: rs.getSize(20),
                    child: VerticalDivider(thickness: rs.getSize(1), color: Theme.of(context).disabledColor)),
                Expanded(
                    child: Text(back,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: rs.getSize(15, bigger: 1.2), color: Theme.of(context).secondaryHeaderColor))),
              ],
            ),
          ),
        ),
        Opacity(
            opacity: card.audio == null ? 0 : 1,
            child: GestureDetector(
                onTap: () {
                  PlayAudio().stop();
                  if (card.isPlay) {
                    setPlayStopIcon(index, isForward: false);
                  } else {
                    PlayAudio().playFlashcard(card.audio!, addStreamCompleted: (event) {
                      if (event.processingState == ProcessingState.completed) {
                        setPlayStopIcon(index, isForward: false);
                        PlayAudio().stream.cancel();
                      }
                    });
                    for (int i = 0; i < controller.cards.length; i++) {
                      if (controller.cards[i].audio != null) {
                        setPlayStopIcon(i, isForward: false);
                      }
                    }
                    setPlayStopIcon(index, isForward: true);
                  }
                },
                child: SizedBox(
                  width: rs.getSize(30),
                  child: card.audio == null ? const SizedBox.shrink() : playStopIcons[card.id]!.icon,
                ))),
      ],
    );
  }
}
