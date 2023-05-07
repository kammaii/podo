import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podo/common/cloud_storage.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/flashcard/flashcard_controller.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class FlashCardMain extends StatefulWidget {
  const FlashCardMain({Key? key}) : super(key: key);

  @override
  _FlashCardMainState createState() => _FlashCardMainState();
}

class _FlashCardMainState extends State<FlashCardMain> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController searchController = TextEditingController();
  final userEmail = 'gabmanpark@gmail.com';
  final USERS = 'Users';
  final FLASHCARDS = 'FlashCards';
  List<FlashCard> cards = [];
  List<FlashCard> cardsSearch = [];
  final controller = Get.put(FlashCardController());
  final duration = const Duration(milliseconds: 200);
  String searchText = '';

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
                    child: FutureBuilder(
                      future:
                          Database().getDocs(collection: '$USERS/$userEmail/$FLASHCARDS', orderBy: 'date'),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                          controller.initChecks(snapshot.data.length);
                          cards = [];
                          for (dynamic snapshot in snapshot.data) {
                            cards.add(FlashCard.fromJson(snapshot));
                          }
                          if (cards.isNotEmpty) {
                            return GetBuilder<FlashCardController>(
                              builder: (_) {
                                int cardsLength = cards.length;
                                if (searchText.isNotEmpty) {
                                  cardsSearch = [];
                                  for (FlashCard card in cards) {
                                    if (searchText.isNotEmpty &&
                                        (card.ko.toLowerCase().contains(searchText) ||
                                            card.fo.toLowerCase().contains(searchText))) {
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
                                                      controller.isChecked[i] ? ids.add(cards[i].id) : null;
                                                    }
                                                    if (ids.isNotEmpty) {
                                                      setState(() {
                                                        String ref = '$USERS/$userEmail/$FLASHCARDS';
                                                        print(ids);
                                                        Future<void> runBatch;
                                                        if (ids.length > 1) {
                                                          runBatch = Database()
                                                              .deleteDocs(collection: ref, ids: ids);
                                                        } else {
                                                          runBatch = Database()
                                                              .deleteDoc(collection: ref, docId: ids[0]);
                                                        }
                                                        runBatch
                                                            .then((value) =>
                                                                Get.snackbar(MyStrings.deleteSucceed, ''))
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
                              },
                            );
                          } else {
                            return Center(child: MyWidget().getTextWidget(text: MyStrings.noFlashCards));
                          }
                        } else {
                          return const Center(child: CircularProgressIndicator());
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
                child: MyWidget().getRoundBtnWidget(
                  isRequest: false,
                  text: MyStrings.review,
                  bgColor: MyColors.purple,
                  fontColor: Colors.white,
                  f: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getFlashCardItem(int index) {
    FlashCard card;
    searchText.isEmpty ? card = cards[index] : card = cardsSearch[index];
    String ko = card.ko;
    String fo = card.fo;

    return Row(
      children: [
        animationWidget(MyWidget().getCheckBox(
            value: controller.isChecked[index],
            onChanged: (value) {
              print(index);
              controller.isChecked[index] = value!;
              controller.update();
            })),
        const SizedBox(width: 10),
        Expanded(
            child:
                Text(ko, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 15))),
        const SizedBox(width: 20, height: 20, child: VerticalDivider(thickness: 1, color: MyColors.grey)),
        Expanded(
            child:
                Text(fo, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 15))),
        Opacity(
          opacity: card.audio == null ? 0 : 1,
          child: IconButton(
            icon: const Icon(
              Icons.volume_up_rounded,
              color: MyColors.purple,
            ),
            onPressed: card.audio == null
                ? null
                : () async {
                    List<String> audioRex = card.audio!.split(RegExp(r'_+'));
                    String url = await CloudStorage().getAudio(folderRef: audioRex[0], fileRef: audioRex[1]);
                    final player = AudioPlayer();
                    await player.setUrl(url);
                    await player.play();
                  },
          ),
        ),
      ],
    );
  }
}
