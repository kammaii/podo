import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:podo/common/local_storage.dart' as ls;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/values/my_colors.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';



class MyTutorial {
  // 로컬 스토리지용 튜토리얼 키
  final TUTORIAL_COURSE = 'tutorialCourse';
  final TUTORIAL_LESSON_LIST = 'tutorialLessonList';
  final TUTORIAL_LESSON_SUMMARY = 'tutorialLessonSummary';
  final TUTORIAL_LESSON_FRAME = 'tutorialLessonFrame';
  final TUTORIAL_LESSON_COMPLETE = 'tutorialLessonComplete';
  final TUTORIAL_READING_FRAME = 'tutorialReadingFrame';
  final TUTORIAL_WRITING_FRAME = 'tutorialWritingFrame';
  final TUTORIAL_FLASHCARD_MAIN = 'tutorialFlashcardMain';

  List<TargetFocus> _targets = [];
  late String _tutorialKey;

  TargetFocus tutorialItem({required String id, GlobalKey? keyTarget, required String content, bool isAlignBottom = true}) {
    return TargetFocus(
      identify: id,
      keyTarget: keyTarget,
      targetPosition: keyTarget == null ? TargetPosition(Size.fromRadius(0), Offset(-20, -20)) : null,
      enableOverlayTab: true,
      alignSkip: isAlignBottom ? Alignment.bottomRight : Alignment.topRight,
      contents: [
        TargetContent(
            align: ContentAlign.custom,
            customPosition: isAlignBottom ? CustomTargetContentPosition(bottom: 30) : CustomTargetContentPosition(top: 30),
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

  addTargetsAndRunTutorial(BuildContext context, List<TargetFocus> tf) {
    _targets = [];
    _targets.addAll(tf);

    WidgetsBinding.instance.addPostFrameCallback((_){
      TutorialCoachMark(
        targets: _targets,
        colorShadow: Colors.transparent,
        onSkip: () {
          setTutorialDisabled();
          FirebaseAnalytics.instance.logEvent(name: 'tutorial_skip', parameters: {'tutorial_key': _tutorialKey});
          print("skip");
          return true;
        },
        onFinish: () {
          setTutorialDisabled();
          FirebaseAnalytics.instance.logEvent(name: 'tutorial_finish', parameters: {'tutorial_key': _tutorialKey});
          print("finish");
        },
      ).show(context: context);
    });
  }


  bool isTutorialEnabled(String tutorialKey) {
    _tutorialKey = tutorialKey;
    //return true; // 튜토리얼 임시 활성화
    return !ls.LocalStorage().getBoolFromLocalStorage(key: tutorialKey); // 튜토리얼을 본 적이 없거나 앱을 재설치 했을 때 true 반환
  }

  setTutorialDisabled() {
    ls.LocalStorage().setBoolToLocalStorage(key: _tutorialKey, value: true);
  }
}
