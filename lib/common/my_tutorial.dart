import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialTargetFocus {
  const TutorialTargetFocus();

  TargetFocus getTarget(
      {required String id,
      required GlobalKey keyTarget,
      required ContentAlign align,
      required String content}) {

    return TargetFocus(identify: id, keyTarget: keyTarget, contents: [
      TargetContent(
          align: align,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/podo.png', width: 50, height: 50),
              const SizedBox(height: 10),
              Text(content, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ))
    ]);
  }

  runTutorial(BuildContext context, List<TargetFocus> targets) {
    TutorialCoachMark(
      targets: targets,
      // List<TargetFocus>
      colorShadow: Colors.transparent,
      // DEFAULT Colors.black
      onClickTarget: (target) {
        print(target);
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print("clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print(target);
      },
      onSkip: () {
        print("skip");
        return true;
      },
      onFinish: () {
        print("finish");
      },
    ).show(context: context);
  }
}
