import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/lesson/lesson.dart';
import 'package:podo/screens/lesson/lesson_controller.dart';
import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:podo/screens/profile/history.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class LessonComplete extends StatelessWidget {
  const LessonComplete({Key? key}) : super(key: key);

  Widget getBtn(String title, IconData icon, Function() fn) {
    return Row(children: [
      Expanded(
          child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: MyColors.purple),
            ),
            backgroundColor: Colors.white),
        onPressed: fn,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 13),
          child: Row(
            children: [
              Icon(icon, color: MyColors.purple),
              const SizedBox(width: 30),
              Expanded(
                  child: Center(child: MyWidget().getTextWidget(text: title, size: 20, color: MyColors.purple))),
            ],
          ),
        ),
      ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final ConfettiController controller = ConfettiController(duration: const Duration(seconds: 10));
    controller.play();
    final lesson = Get.arguments;
    final lessonController = Get.find<LessonController>();
    History().addHistory(item: 'lesson', itemId: lesson.id);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      lessonController.isCompleted[lesson.id] = true;
    });

    return Scaffold(
      backgroundColor: MyColors.purpleLight,
      body: SafeArea(
        child: Stack(
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
                  text: MyStrings.congratulations,
                  textStyle: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
                  waveColor: MyColors.purple,
                  boxBackgroundColor: MyColors.purpleLight,
                  boxHeight: 100,
                ),
                const Divider(
                  thickness: 1,
                  indent: 30,
                  endIndent: 30,
                ),
                const SizedBox(
                  height: 20,
                ),
                MyWidget().getTextWidget(
                  text: MyStrings.lessonComplete,
                  size: 20,
                  color: MyColors.purple,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        getBtn(MyStrings.summary, CupertinoIcons.doc_text, () {
                          Get.until((route) => Get.currentRoute == MyStrings.routeLessonSummaryMain);
                        }),
                        const SizedBox(height: 20),
                        getBtn(MyStrings.writing, CupertinoIcons.pen, () {
                          Get.offNamedUntil(MyStrings.routeWritingMain, ModalRoute.withName(MyStrings.routeLessonSummaryMain),
                              arguments: lesson.id);
                        }),
                        const SizedBox(height: 20),
                        getBtn(MyStrings.nextLesson, CupertinoIcons.arrow_right, () {
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
                            Get.offNamedUntil(MyStrings.routeLessonSummaryMain, ModalRoute.withName('/'),
                                arguments: Lesson.fromJson(lessons[nextIndex] as Map<String, dynamic>));
                          } else {
                            Get.until((route) => Get.currentRoute == '/');
                            MyWidget().showSnackbar(title: MyStrings.lastLesson);
                          }
                        }),
                        const SizedBox(height: 20),
                        getBtn(MyStrings.goToMain, CupertinoIcons.home, () {
                          Get.until((route) => Get.currentRoute == '/');
                        }),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget getCircleBtn(Icon icon, String text) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(
            color: MyColors.purple,
            width: 3,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(50),
          ),
        ),
        child: IconButton(
          icon: icon,
          iconSize: 40,
          color: MyColors.purple,
          onPressed: () {},
        ),
      ),
      const SizedBox(
        height: 5,
      ),
      MyWidget().getTextWidget(
        text: text,
        size: 17,
        color: MyColors.purple,
      )
    ],
  );
}
