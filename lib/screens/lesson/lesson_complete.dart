import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:podo/common/history.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/lesson/lesson.dart';
import 'package:podo/screens/lesson/lesson_controller.dart';
import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class LessonComplete extends StatelessWidget {
  LessonComplete({Key? key}) : super(key: key);

  late ResponsiveSize rs;
  bool isPremiumUser = false;
  bool isFreeOptions = false;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Widget getBtn(BuildContext context, String title, IconData icon, Function() fn) {
    return Row(children: [
      Expanded(
          child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: Theme.of(context).primaryColor),
            ),
            backgroundColor: Theme.of(context).cardColor),
        onPressed: fn,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: rs.getSize(30), vertical: rs.getSize(13)),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: rs.getSize(20)),
              SizedBox(width: rs.getSize(30)),
              Expanded(
                child: Center(
                  child: MyWidget().getTextWidget(rs, text: title, size: 20, color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
      ))
    ]);
  }

  void playYay() async {
    PlayAudio().playYay();
  }

  void showReviewRequest() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await analytics.logEvent(name: 'review_requested');
      await inAppReview.requestReview();
    }
  }

  @override
  Widget build(BuildContext context) {
    rs = ResponsiveSize(context);
    playYay();
    final ConfettiController controller = ConfettiController(duration: const Duration(seconds: 10));
    controller.play();
    final lesson = Get.arguments;
    final lessonController = Get.find<LessonController>();
    if (User().status == 2 || User().status == 3) {
      isPremiumUser = true;
    }
    if (lesson.isFreeOptions != null && lesson.isFreeOptions) {
      isFreeOptions = true;
    }
    History().addHistory(itemIndex: 0, itemId: lesson.id, content: lesson.title['ko']);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      lessonController.isCompleted[lesson.id] = true;
      if (LocalStorage().histories.isNotEmpty && LocalStorage().histories.length % 7 == 0) {
        showReviewRequest();
      }

      // trial mode 설정 여부 확인
      bool trialEnabled = User().isFreeTrialEnabled == true && User().trialStart == null;
      if (trialEnabled) {
        MyWidget().showDialog(context, rs,
            content: tr('tutorial_lesson_complete_1'),
            hasNoBtn: false,
            yesText: tr('tutorial_lesson_complete_2'), barrierDismissible: false, yesFn: () {
          MyWidget().showDialog(context, rs,
              content: tr('tutorial_lesson_complete_3'),
              hasNoBtn: false,
              yesText: tr('tutorial_lesson_complete_4'), barrierDismissible: false, yesFn: () {
            MyWidget().showDialog(context, rs,
                content: tr('tutorial_lesson_complete_5'),
                hasNoBtn: false,
                yesText: tr('tutorial_lesson_complete_6'), barrierDismissible: false, yesFn: () async {
              await User().setTrialAuthorized();
              MyWidget().showSnackbarWithPodo(rs, title: tr('congratulations'), content: tr('trialActivated'));
              Get.offNamedUntil(MyStrings.routeMainFrame, ModalRoute.withName(MyStrings.routeLogo));
            });
          });
        });
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Image.asset('assets/images/bubble_top.png', fit: BoxFit.fill),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Image.asset('assets/images/bubble_bottom.png', fit: BoxFit.fill),
            ),
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
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: rs.getSize(20)),
              MyWidget().getTextWidget(rs,
                  text: tr('congratulations'), size: 30, isBold: true, color: Theme.of(context).primaryColor),
              Divider(
                thickness: rs.getSize(1),
                indent: rs.getSize(30),
                endIndent: rs.getSize(30),
              ),
              SizedBox(height: rs.getSize(20)),
              MyWidget().getTextWidget(
                rs,
                text: tr('lessonComplete'),
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: rs.getSize(20)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: rs.getSize(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      lesson.hasOptions
                          ? Column(
                              children: [
                                getBtn(context, tr('summary'), CupertinoIcons.doc_text, () {
                                  Get.until((route) => Get.currentRoute == MyStrings.routeLessonSummaryMain);
                                }),
                                SizedBox(height: rs.getSize(20)),
                                getBtn(context, tr('writing'), CupertinoIcons.pen, () {
                                  if (isPremiumUser || isFreeOptions) {
                                    Get.offNamedUntil(MyStrings.routeWritingMain,
                                        ModalRoute.withName(MyStrings.routeLessonSummaryMain),
                                        arguments: lesson.id);
                                  } else {
                                    MyWidget().showDialog(context, rs, content: tr('wantUnlockLesson'), yesFn: () {
                                      Get.toNamed(MyStrings.routePremiumMain);
                                    }, hasPremiumTag: true, hasNoBtn: false, yesText: tr('explorePremium'));
                                  }
                                }),
                                SizedBox(height: rs.getSize(20)),
                                lesson.isReadingReleased
                                    ? getBtn(context, tr('reading'), CupertinoIcons.book, () {
                                        if (isPremiumUser || isFreeOptions) {
                                          Get.offNamedUntil(MyStrings.routeReadingFrame,
                                              ModalRoute.withName(MyStrings.routeLessonSummaryMain),
                                              arguments: lesson.readingId);
                                        } else {
                                          MyWidget().showDialog(context, rs, content: tr('wantUnlockLesson'),
                                              yesFn: () {
                                            Get.toNamed(MyStrings.routePremiumMain);
                                          }, hasPremiumTag: true, hasNoBtn: false, yesText: tr('explorePremium'));
                                        }
                                      })
                                    : const SizedBox.shrink(),
                                //todo: speaking, reading 버튼 추가
                                Divider(
                                  thickness: rs.getSize(1),
                                  indent: rs.getSize(30),
                                  endIndent: rs.getSize(30),
                                  height: rs.getSize(30),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                      User().status != 1
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: getBtn(context, tr('nextLesson'), CupertinoIcons.arrow_right, () {
                                LessonCourse course = LocalStorage().getLessonCourse()!;
                                List<dynamic> lessons = course.lessons;
                                int thisIndex = -1;
                                for (int i = 0; i < lessons.length; i++) {
                                  print('$i : ${lessons[i] is String}');
                                  if (lessons[i] is! String &&
                                      lesson.id == Lesson.fromJson(lessons[i] as Map<String, dynamic>).id) {
                                    thisIndex = i;
                                    break;
                                  }
                                }

                                if (thisIndex != -1 && thisIndex < lessons.length - 1) {
                                  int nextIndex = thisIndex + 1;
                                  if (lessons[nextIndex] is String) {
                                    nextIndex++;
                                  }
                                  Lesson nextLesson = Lesson.fromJson(lessons[nextIndex] as Map<String, dynamic>);
                                  if (nextLesson.hasOptions) {
                                    Get.offNamedUntil(
                                        MyStrings.routeLessonSummaryMain, ModalRoute.withName(MyStrings.routeMainFrame),
                                        arguments: nextLesson);
                                  } else {
                                    Get.offNamedUntil(
                                        MyStrings.routeLessonFrame, ModalRoute.withName(MyStrings.routeMainFrame),
                                        arguments: nextLesson);
                                  }
                                } else {
                                  Get.until((route) => Get.currentRoute == MyStrings.routeMainFrame);
                                  MyWidget().showSnackbar(rs, title: tr('lastLesson'));
                                }
                              }),
                            )
                          : const SizedBox.shrink(),
                      getBtn(context, tr('goToMain'), CupertinoIcons.home, () {
                        Get.until((route) => Get.currentRoute == MyStrings.routeMainFrame);
                      }),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget getCircleBtn(BuildContext context, Icon icon, String text) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).cardColor,
          padding: EdgeInsets.all(rs.getSize(5)),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 3,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
          ),
          child: IconButton(
            icon: icon,
            iconSize: rs.getSize(40),
            color: Theme.of(context).primaryColor,
            onPressed: () {},
          ),
        ),
        SizedBox(height: rs.getSize(5)),
        MyWidget().getTextWidget(
          rs,
          text: text,
          size: 17,
          color: Theme.of(context).primaryColor,
        )
      ],
    );
  }
}
