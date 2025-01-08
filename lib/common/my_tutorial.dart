import 'dart:io';
import 'package:podo/common/local_storage.dart' as ls;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/values/my_colors.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';



class MyTutorial {
  // 로컬 스토리지용 튜토리얼 키
  static const TUTORIAL_COURSE = 'tutorialCourse';
  static const TUTORIAL_LESSON_LIST = 'tutorialLessonList';
  static const TUTORIAL_LESSON_SUMMARY = 'tutorialLessonSummary';
  static const TUTORIAL_LESSON_FRAME = 'tutorialLessonFrame';
  static const TUTORIAL_LESSON_COMPLETE = 'tutorialLessonComplete';
  static const TUTORIAL_READING_FRAME = 'tutorialReadingFrame';
  static const TUTORIAL_WRITING_FRAME = 'tutorialWritingFrame';
  static const TUTORIAL_FLASHCARD_MAIN = 'tutorialFlashcardMain';

  TargetFocus tutorialItem({required String id, GlobalKey? keyTarget, required String content}) {
    return TargetFocus(
      identify: id,
      keyTarget: keyTarget,
      targetPosition: keyTarget == null ? TargetPosition(Size.fromRadius(0), Offset(-20, -20)) : null,
      enableOverlayTab: true,
      alignSkip: Alignment.bottomRight,
      contents: [
        TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(bottom: 30),
            padding: const EdgeInsets.all(20),
            child: IgnorePointer(
              ignoring: true,
              child: MyWidget().getRoundedContainer(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/podo.png', width: 50, height: 50),
                  const SizedBox(height: 20),
                  Text(
                    content,
                    style: TextStyle(
                      color: MyColors.purple,
                      fontSize: 20,
                      fontFamily: Platform.isIOS ? null : 'EnglishFont',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )),
            ))
      ],
    );
  }

  runTutorial(BuildContext context, List<TargetFocus> targets, String tutorialKey) {
    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.transparent,
      onSkip: () {
        setTutorialDisabled(tutorialKey);
        print("skip");
        return true;
      },
      onFinish: () {
        setTutorialDisabled(tutorialKey);
        print("finish");
      },
    ).show(context: context);
  }

  bool isTutorialEnabled(String tutorialKey) {
    return ls.LocalStorage().getBoolFromLocalStorage(key: tutorialKey, defaultValue: true);
  }

  setTutorialDisabled(String tutorialKey) {
    ls.LocalStorage().setBoolToLocalStorage(key: tutorialKey, value: false);
  }
}
