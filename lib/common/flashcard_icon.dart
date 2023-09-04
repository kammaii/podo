import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:podo/values/my_colors.dart';

class FlashcardIcon {
  Widget getIcon(
      {required dynamic controller, required String itemId, required String front, String? back, String? audio}) {
    return Stack(
      children: [
        IconButton(
          padding: const EdgeInsets.all(5),
          constraints: const BoxConstraints(),
          onPressed: () {
            if (controller.hasFlashcard[itemId]) {
              FlashCard().removeFlashcard(itemId: itemId);
              controller.hasFlashcard[itemId] = false;
            } else {
              FlashCard().addFlashcard(
                itemId: itemId,
                front: front,
                back: back,
                audio: audio,
                fn: () {
                  controller.hasFlashcard[itemId] = true;
                },
              );
            }
          },
          icon: Icon(
            controller.hasFlashcard[itemId] ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
            color: MyColors.purple,
          ),
        ),
        controller.hasFlashcard[itemId]
            ? const SizedBox.shrink()
            : const Icon(CupertinoIcons.plus_circle_fill, color: MyColors.purple, size: 13),
      ],
    );
  }
}
