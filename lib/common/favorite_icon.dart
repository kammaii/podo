import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/values/my_colors.dart';

class FavoriteIcon {
  Widget getFlashcardIcon(BuildContext context, ResponsiveSize rs,
      {required dynamic controller, required String itemId, required String front, String? back, String? audio}) {
    if (controller.hasFlashcard[itemId] == null) {
      controller.hasFlashcard[itemId] = LocalStorage().hasFlashcard(itemId: itemId);
    }

    return getIcon(context, rs, b: controller.hasFlashcard[itemId], fn: () {
      if (controller.hasFlashcard[itemId]) {
        FlashCard().removeFlashcard(itemId: itemId);
        controller.hasFlashcard[itemId] = false;
      } else {
        FlashCard().addFlashcard(
          context,
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
    });
  }

  Widget getFavoriteLessonIcon(BuildContext context, ResponsiveSize rs,
      {required dynamic controller, required dynamic item, required bool isReading}) {
    String ref = isReading ? 'Users/${User().id}/Readings' : 'Users/${User().id}/Speakings';

    return getIcon(context, rs, b: controller.hasFavoriteLesson.value, fn: () {
      if (controller.hasFavoriteLesson.value) {
        Database().deleteDoc(collection: ref, docId: item.id);
        controller.hasFavoriteLesson.value = false;
      } else {
        Database().setDoc(collection: ref, doc: item);
        controller.hasFavoriteLesson.value = true;
      }
    }, isWhiteIcon: true);
  }

  Widget getIcon(BuildContext context, ResponsiveSize rs,
      {bool b = false, Function()? fn, bool isWhiteIcon = false}) {
    return Stack(
      children: [
        Theme(
          data: Theme.of(context).copyWith(highlightColor: MyColors.navyLight),
          child: IconButton(
            padding: EdgeInsets.all(rs.getSize(5, bigger: 1.2)),
            constraints: const BoxConstraints(),
            onPressed: fn,
            icon: Icon(
              b ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
              color: isWhiteIcon ? Colors.white : Theme.of(context).primaryColor,
              size: rs.getSize(20),
            ),
          ),
        ),
        b
            ? const SizedBox.shrink()
            : Icon(CupertinoIcons.plus_circle_fill,
                color: isWhiteIcon ? Colors.white : Theme.of(context).primaryColor, size: rs.getSize(13)),
      ],
    );
  }
}
