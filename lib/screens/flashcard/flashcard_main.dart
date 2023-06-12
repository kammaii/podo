import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podo/common/cloud_storage.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_Stop_icon.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/flashcard/flashcard_controller.dart';
import 'package:podo/screens/flashcard/flashcard_edit.dart';
import 'package:podo/screens/flashcard/flashcard_review.dart';
import 'package:podo/screens/loading_controller.dart';
import 'package:podo/screens/profile/user_info.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class FlashCardMain extends StatefulWidget {
  const FlashCardMain({Key? key}) : super(key: key);

  @override
  _FlashCardMainState createState() => _FlashCardMainState();
}

class _FlashCardMainState extends State<FlashCardMain> with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController searchController = TextEditingController();
  final ref = 'Users/${User().email}/FlashCards';
  List<FlashCard> cardsSearch = [];
  final controller = Get.put(FlashCardController());
  final duration = const Duration(milliseconds: 200);
  String searchText = '';
  Map<String, PlayStopIcon> playStopIcons = {};
  final int docsLimit = 12; //todo: 20 개 이상으로 변경
  final scrollController = ScrollController();
  late int cardsLength;
  DocumentSnapshot? lastSnapshot;


  @override
  void initState() {
    super.initState();
    controller.init();
    loadFlashcards();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        LoadingController.to.isLoading = true;
        loadFlashcards(isContinue: true);
        LoadingController.to.isLoading = false;
      }
    });
  }

  loadFlashcards({bool isContinue = false}) async {
    Query query = FirebaseFirestore.instance.collection(ref).orderBy('date', descending: true).limit(docsLimit);
    if(isContinue) {
      query = query.startAfterDocument(lastSnapshot!);
    }
    List<dynamic> snapshots = await Database().getDocs(query: query);

    if(snapshots.isNotEmpty) {
      for (dynamic snapshot in snapshots) {
        FlashCard card = FlashCard.fromJson(snapshot.data() as Map<String, dynamic>);
        controller.cards.add(card);
        controller.isChecked.add(false);
        if (card.audio != null) {
          playStopIcons[card.id] = PlayStopIcon(this);
        }
      }
      lastSnapshot = snapshots.last;
    }
    controller.update();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    searchController.dispose();
    scrollController.dispose();
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
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  MyWidget().getSearchWidget(
                      focusNode: _focusNode,
                      controller: searchController,
                      hint: MyStrings.search,
                      onChanged: (text) {
                        searchText = searchController.text;
                        controller.update();
                      }),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GetBuilder<FlashCardController>(
                      builder: (_) {
                        if (controller.cards.isNotEmpty) {
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
                                    animationWidget(MyWidget().getCheckBox(
                                        value: controller.isCheckedAll,
                                        onChanged: (value) {
                                          controller.isCheckedAllClicked(value!);
                                        })),
                                    Row(
                                      children: [
                                        animationWidget(IconButton(
                                            onPressed: () {
                                              List<String> ids = [];
                                              for (int i = 0; i < controller.isChecked.length; i++) {
                                                controller.isChecked[i] ? ids.add(controller.cards[i].id) : null;
                                              }
                                              if (ids.isNotEmpty) {
                                                setState(() {
                                                  Future<void> runBatch;
                                                  if (ids.length > 1) {
                                                    runBatch = Database().deleteDocs(collection: ref, ids: ids);
                                                  } else {
                                                    runBatch =
                                                        Database().deleteDoc(collection: ref, docId: ids[0]);
                                                  }
                                                  runBatch
                                                      .then((value) => Get.snackbar(MyStrings.deleteSucceed, ''))
                                                      .onError((error, stackTrace) =>
                                                          Get.snackbar(MyStrings.deleteFailed, ''));
                                                });
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: MyColors.red,
                                            ))),
                                        const SizedBox(width: 20),
                                        MyWidget().getTextWidget(
                                            text: '$cardsLength ${MyStrings.cards}',
                                            size: 15,
                                            color: Colors.black),
                                      ],
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _focusNode.unfocus();
                                    },
                                    onLongPress: () {
                                      controller.isLongClicked = !controller.isLongClicked;
                                      controller.update();
                                    },
                                    child: ListView.builder(
                                      controller: scrollController,
                                      padding: const EdgeInsets.only(top: 10, bottom: 80),
                                      itemCount: cardsLength,
                                      itemBuilder: (BuildContext context, int index) {
                                        return getFlashCardItem(index);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Center(child: MyWidget().getTextWidget(text: MyStrings.noFlashCards));
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Container(
                alignment: Alignment.bottomCenter,
                child: GetBuilder<FlashCardController>(
                  builder: (_) {
                    return MyWidget().getRoundBtnWidget(
                      text: MyStrings.review,
                      bgColor: controller.cards.isNotEmpty ? MyColors.purple : MyColors.grey,
                      fontColor: Colors.white,
                      f: onReviewBtn,
                      hasNullFunction: true,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Function? onReviewBtn() {
    if (controller.cards.isNotEmpty) {
      return () {
        Get.to(const FlashCardReview(), arguments: controller.cards);
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

  Widget getFlashCardItem(int index) {
    FlashCard card;
    searchText.isEmpty ? card = controller.cards[index] : card = cardsSearch[index];
    String front = card.front;
    String back = card.back;

    return Row(
      children: [
        animationWidget(MyWidget().getCheckBox(
            value: controller.isChecked[index],
            onChanged: (value) {
              controller.isChecked[index] = value!;
              controller.update();
            })),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Get.to(FlashCardEdit(), arguments: card);
            },
            child: Row(
              children: [
                Expanded(
                    child: Text(front,
                        overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 15))),
                const SizedBox(width: 20, height: 20, child: VerticalDivider(thickness: 1, color: MyColors.grey)),
                Expanded(
                    child: Text(back,
                        overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 15))),
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
                  width: 30,
                  child: card.audio == null ? const SizedBox.shrink() : playStopIcons[card.id]!.icon,
                ))),
      ],
    );
  }
}
