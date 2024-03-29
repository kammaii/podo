import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
                  child:
                      MyWidget().getTextWidget(rs, text: title, size: 20, color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
      ))
    ]);
  }

  void showMessagePermission() async {
    await FirebaseAnalytics.instance.logEvent(name: 'first_lesson_complete');
    Get.dialog(
        AlertDialog(
          title: Image.asset('assets/images/podo.png', width: rs.getSize(50), height: rs.getSize(50)),
          content: MyWidget().getTextWidget(rs, text: tr('trialComment'), isTextAlignCenter: true, size: 16),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: EdgeInsets.all(rs.getSize(20)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: MyColors.purple),
              onPressed: () async {
                Get.back();
                FirebaseMessaging messaging = FirebaseMessaging.instance;
                NotificationSettings settings = await messaging.requestPermission();
                if (settings.authorizationStatus == AuthorizationStatus.authorized) {
                  await FirebaseAnalytics.instance.logEvent(name: 'fcm_approved');
                  await User().setTrialAuthorized(rs, true);
                  MyWidget().showSnackbarWithPodo(rs, title: tr('congratulations'), content: tr('trialActivated'));
                  Get.offNamedUntil(MyStrings.routeMainFrame, ModalRoute.withName(MyStrings.routeLogo));
                } else {
                  await FirebaseAnalytics.instance.logEvent(name: 'fcm_denied');
                  await User().setTrialAuthorized(rs, false);
                  Get.defaultDialog(
                      title: tr('trialDenyTitle'),
                      content: Center(child: Text(tr('trialDenyContent'), textAlign: TextAlign.center)),
                      titlePadding: const EdgeInsets.all(10),
                      contentPadding: const EdgeInsets.all(10),
                      buttonColor: MyColors.purple,
                      confirmTextColor: Colors.white,
                      barrierDismissible: false,
                      onConfirm: () {
                        Get.offNamedUntil(MyStrings.routeMainFrame, ModalRoute.withName(MyStrings.routeLogo));
                      });
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: rs.getSize(13)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: rs.getSize(15), vertical: rs.getSize(3)),
                  child: MyWidget().getTextWidget(rs, text: tr('cool'), color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false);
  }

  void playYay() async {
    PlayAudio().playYay();
  }

  void showReviewRequest() async {
    FirebaseAnalytics.instance.logEvent(name: 'review_requested');
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
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
    History().addHistory(itemIndex: 0, itemId: lesson.id);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      lessonController.isCompleted[lesson.id] = true;
      if (User().status == 0 && User().trialStart == null) {
        showMessagePermission();
      }
      if (LocalStorage().histories.length % 3 == 0) {
        showReviewRequest();
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
            gravity: 0.05,
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
              TextLiquidFill(
                loadDuration: const Duration(seconds: 2),
                text: tr('congratulations'),
                textStyle: TextStyle(fontSize: rs.getSize(30), fontWeight: FontWeight.bold, color: Colors.white),
                waveColor: Theme.of(context).primaryColor,
                boxBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
                boxHeight: rs.getSize(100),
              ),
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
                                  if (User().status == 2 || User().status == 3) {
                                    Get.offNamedUntil(MyStrings.routeWritingMain,
                                        ModalRoute.withName(MyStrings.routeLessonSummaryMain),
                                        arguments: lesson.id);
                                  } else {
                                    Get.toNamed(MyStrings.routePremiumMain);
                                  }
                                }),
                                SizedBox(height: rs.getSize(20)),
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
                                  Lesson nextLesson =
                                      Lesson.fromJson(lessons[nextIndex] as Map<String, dynamic>);
                                  if (nextLesson.hasOptions) {
                                    Get.offNamedUntil(MyStrings.routeLessonSummaryMain,
                                        ModalRoute.withName(MyStrings.routeMainFrame),
                                        arguments: nextLesson);
                                  } else {
                                    Get.offNamedUntil(MyStrings.routeLessonFrame,
                                        ModalRoute.withName(MyStrings.routeMainFrame),
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

  // void showAd(Function() fn) {
  //   if (User().status == 1) {
  //     if (AdsController().interstitialAd != null) {
  //       AdsController().showInterstitialAd((ad) {
  //         fn();
  //         ad.dispose();
  //       });
  //     } else {
  //       fn();
  //     }
  //   } else {
  //     fn();
  //   }
  // }

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
