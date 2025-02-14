import 'dart:io';
import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:podo/common/local_storage.dart' as ls;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/screens/my_page/user.dart';
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

  TargetFocus tutorialItem(
      {required String id, GlobalKey? keyTarget, required String content, bool isAlignBottom = true}) {
    return TargetFocus(
      identify: id,
      keyTarget: keyTarget,
      targetPosition: keyTarget == null ? TargetPosition(Size.fromRadius(0), Offset(-20, -20)) : null,
      enableOverlayTab: true,
      alignSkip: isAlignBottom ? Alignment.bottomRight : Alignment.topRight,
      contents: [
        TargetContent(
            align: ContentAlign.custom,
            customPosition:
                isAlignBottom ? CustomTargetContentPosition(bottom: 30) : CustomTargetContentPosition(top: 30),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialCoachMark(
        targets: _targets,
        colorShadow: Colors.transparent,
        onSkip: () {
          setTutorialDisabled('skip');
          print("skip");
          return true;
        },
        onFinish: () {
          setTutorialDisabled('finish');
          print("finish");
        },
      ).show(context: context);
    });
  }

  bool isTutorialEnabled(String tutorialKey) {
    _tutorialKey = tutorialKey;
    return !ls.LocalStorage().getBoolFromLocalStorage(key: tutorialKey); // 튜토리얼을 본 적이 없거나 앱을 재설치 했을 때 true 반환
  }

  setTutorialDisabled(String status) async {
    await FirebaseAnalytics.instance
        .logEvent(name: 'tutorial_end', parameters: {'tutorial_key': _tutorialKey, 'status': status});
    ls.LocalStorage().setBoolToLocalStorage(key: _tutorialKey, value: true);

    // 첫 레슨 완료 유도
    print('유저: ${User().isFreeTrialEnabled}');
    if (_tutorialKey == TUTORIAL_LESSON_LIST && User().isFreeTrialEnabled == true && User().trialStart == null) {
      final ConfettiController controller = ConfettiController();
      controller.play();
      PlayAudio().playYay();
      Get.dialog(
          Stack(
            children: [
              AlertDialog(
                backgroundColor: Colors.white,
                icon: Center(child: Image.asset('assets/images/treasure_box.png', width: 100, height: 100)),
                title: Text(
                  tr('free_premium_title'),
                  style: TextStyle(
                      fontFamily: (Platform.isIOS ? null : 'EnglishFont'),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MyColors.purple),
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  tr('free_premium_content'),
                  style: TextStyle(
                      fontFamily: (Platform.isIOS ? null : 'EnglishFont'), fontSize: 18, color: MyColors.purple),
                  textAlign: TextAlign.center,
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            side: BorderSide(color: MyColors.purple, width: 1),
                            backgroundColor: MyColors.purple),
                        onPressed: () {
                          Get.back();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 13),
                          child: Text(tr('free_premium_button'),
                              style: TextStyle(
                                  fontFamily: (Platform.isIOS ? null : 'EnglishFont'),
                                  color: Colors.white,
                                  fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(tr('free_premium_limit'),
                          style: TextStyle(
                              fontFamily: (Platform.isIOS ? null : 'EnglishFont'),
                              color: MyColors.purple,
                              fontSize: 13,
                              decoration: TextDecoration.underline)),
                    ],
                  )
                ],
              ),
              ConfettiWidget(
                confettiController: controller,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: true,
                gravity: 0.1,
                colors: const [
                  MyColors.pink,
                  MyColors.mustardLight,
                  MyColors.navyLight,
                  MyColors.greenLight,
                ],
              ),
            ],
          ),
          barrierDismissible: false);
    }
  }
}
