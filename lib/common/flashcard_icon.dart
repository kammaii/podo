import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:podo/values/my_colors.dart';

class FlashcardIcon {
  Widget getIconButton(BuildContext context, ResponsiveSize rs,
      {required dynamic controller,
      required String itemId,
      required String front,
      String? back,
      String? audio}) {
    if(controller.hasFlashcard[itemId] == null) {
      controller.hasFlashcard[itemId] = LocalStorage().hasFlashcard(itemId: itemId);
    }

    return Stack(
      children: [
        Theme(
          data: Theme.of(context).copyWith(highlightColor: MyColors.navyLight),
          child: IconButton(
            padding: EdgeInsets.all(rs.getSize(5, bigger: 1.2)),
            constraints: const BoxConstraints(),
            onPressed: () {
              if (controller.hasFlashcard[itemId]) {
                FlashCard().removeFlashcard(itemId: itemId);
                controller.hasFlashcard[itemId] = false;
              } else {
                FlashCard().addFlashcard(context,
                  rs,
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
              controller.hasFlashcard[itemId]
                  ? FontAwesomeIcons.solidStar
                  : FontAwesomeIcons.star,
              color: Theme.of(context).primaryColor,
              size: rs.getSize(20),
            ),
          ),
        ),
        controller.hasFlashcard[itemId]
            ? const SizedBox.shrink()
            : Icon(CupertinoIcons.plus_circle_fill,
                color: Theme.of(context).primaryColor, size: rs.getSize(13)),
      ],
    );
  }

  Widget getIconOnly(ResponsiveSize rs) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(FontAwesomeIcons.star,
              color: MyColors.purple, size: rs.getSize(30)),
        ),
        Icon(CupertinoIcons.plus_circle_fill,
            color: MyColors.purple, size: rs.getSize(13))
      ],
    );
  }
}
