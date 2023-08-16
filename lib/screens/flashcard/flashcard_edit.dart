import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/flashcard/flashcard_controller.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class FlashCardEdit extends StatelessWidget {
  FlashCardEdit({Key? key}) : super(key: key);

  late FlashCard card;
  bool isCorrected = false;
  late String front;
  late String back;
  final FocusNode _focusNodeFront = FocusNode();
  final FocusNode _focusNodeBack = FocusNode();

  Function? onSaveBtn() {
    if (isCorrected) {
      return () {
        _focusNodeFront.unfocus();
        _focusNodeBack.unfocus();
        card.front = front;
        card.back = back;
        Get.back();
        FlashCard().updateFlashcard(card: card);
      };
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    card = Get.arguments;
    front = card.front;
    back = card.back;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: MyColors.purple,
          ),
          title: Text(tr('flashcardEdit'), style: const TextStyle(color: MyColors.purple)),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
                  child: Center(
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: MyWidget().getTextFieldWidget(
                                focusNode: _focusNodeFront,
                                controller: TextEditingController(text: front),
                                hint: 'front',
                                fontSize: 20,
                                maxLines: 5,
                                onChanged: (text) {
                                  front = text;
                                  Get.find<FlashCardController>().update();
                                }),
                          ),
                        ),
                        const Divider(height: 10),
                        Expanded(
                          child: Center(
                            child: MyWidget().getTextFieldWidget(
                                focusNode: _focusNodeBack,
                                controller: TextEditingController(text: back),
                                hint: 'back',
                                fontSize: 20,
                                maxLines: 5,
                                onChanged: (text) {
                                  back = text;
                                  Get.find<FlashCardController>().update();
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            GetBuilder<FlashCardController>(
              builder: (controller) {
                isCorrected = false;
                if (front != card.front || back != card.back) {
                  isCorrected = true;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: MyWidget().getRoundBtnWidget(
                            text: tr('save'),
                            verticalPadding: 10,
                            hasNullFunction: true,
                            f: onSaveBtn,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
