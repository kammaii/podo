import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/ads_controller.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_tutorial.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/lesson/lesson.dart';
import 'package:podo/screens/lesson/lesson_controller.dart';
import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:podo/screens/lesson/lesson_course_controller.dart';
import 'package:podo/screens/main_frame.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class LessonCourseList extends StatefulWidget {
  const LessonCourseList({super.key});

  @override
  State<LessonCourseList> createState() => _LessonCourseListState();
}

class _LessonCourseListState extends State<LessonCourseList> with SingleTickerProviderStateMixin {
  static const IS_GRAMMAR_MODE = 'isGrammarMode';
  List<bool> modeToggle = [true, false];
  String setLanguage = User().language;
  final controller = Get.find<LessonCourseController>();
  List<LessonCourse> courses = [];
  late ResponsiveSize rs;
  MyTutorial? myTutorial;
  bool isTutorialEnabled = false;

  // 튜토리얼 포커스용 키
  GlobalKey? keyTopicMode;
  GlobalKey? keyGrammarMode;
  GlobalKey? keyCourse;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController searchController = TextEditingController();
  String searchText = '';
  final KO = 'ko';
  final lessonController =
      Get.isRegistered<LessonController>() ? Get.find<LessonController>() : Get.put(LessonController());
  List<Lesson> searchedLessons = [];

  @override
  void dispose() {
    _focusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  Widget getLessonCourseList({required bool isFirst, required LessonCourse lessonCourse}) {
    bool hasTag = lessonCourse.tag != null && lessonCourse.tag!.isNotEmpty;
    String level = '';
    if (hasTag) {
      level = tr(lessonCourse.tag!);
    }
    return Column(
      children: [
        Visibility(
          visible: hasTag,
          child: Padding(
            padding: EdgeInsets.only(top: rs.getSize(35), bottom: rs.getSize(5)),
            child: MyWidget()
                .getTextWidget(rs, text: level, size: rs.getSize(35), isBold: true, color: MyColors.navyLight),
          ),
        ),
        Card(
          key: isFirst && isTutorialEnabled ? keyCourse : null,
          color: Theme.of(context).cardColor,
          child: InkWell(
            onTap: () {
              LocalStorage().setLessonCourse(lessonCourse, resetPosition: true);
              controller.update();
              if (isTutorialEnabled) {
                MainFrame.shouldRunLessonListTutorial = true;
              }
              Get.back();
            },
            child: Padding(
              padding: EdgeInsets.all(rs.getSize(15)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      lessonCourse.image != null
                          ? Padding(
                              padding: EdgeInsets.only(right: rs.getSize(20)),
                              child: Image.memory(base64Decode(lessonCourse.image!),
                                  height: rs.getSize(80), width: rs.getSize(80)),
                            )
                          : const SizedBox.shrink(),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(Icons.play_lesson_rounded, color: MyColors.navy, size: 18),
                                const SizedBox(width: 5),
                                MyWidget().getTextWidget(rs,
                                    text: lessonCourse.lessons.length.toString(), color: MyColors.navy),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: MyWidget().getTextWidget(
                                    rs,
                                    text: lessonCourse.title[setLanguage],
                                    size: 20,
                                    color: Theme.of(context).primaryColor,
                                    isBold: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: modeToggle[0] ? rs.getSize(20) : 0),
                  modeToggle[0]
                      ? MyWidget().getTextWidget(
                          rs,
                          text: lessonCourse.description[setLanguage],
                          color: Theme.of(context).disabledColor,
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  runLesson(Lesson lesson) async {
    await FirebaseAnalytics.instance.logSelectContent(
        contentType: 'lesson',
        itemId: lesson.title[KO],
        parameters: {'course_title': lesson.courseTitle!, 'course_mode': 'Grammar'});
    if (!lesson.hasOptions) {
      Get.toNamed(MyStrings.routeLessonFrame, arguments: lesson);
    } else {
      Get.toNamed(MyStrings.routeLessonSummaryMain, arguments: lesson);
    }
  }

  Widget getSearchedGrammarList(int index, Lesson lesson) {
    bool isPremiumUser;
    User().status == 2 || User().status == 3 ? isPremiumUser = true : isPremiumUser = false;
    bool isLocked = !lesson.isFree && !isPremiumUser;
    List<Widget> optionIcons = [];
    if (lesson.hasOptions) {
      optionIcons.add(Icon(FontAwesomeIcons.pen, color: Theme.of(context).primaryColorDark, size: rs.getSize(13)));
    }
    if (lesson.isReadingReleased) {
      optionIcons.add(SizedBox(width: rs.getSize(8)));
      optionIcons
          .add(Icon(FontAwesomeIcons.book, color: Theme.of(context).primaryColorDark, size: rs.getSize(13)));
    }
    if (lesson.isSpeakingReleased) {
      optionIcons.add(SizedBox(width: rs.getSize(8)));
      optionIcons.add(
          Icon(CupertinoIcons.bubble_right_fill, color: Theme.of(context).primaryColorDark, size: rs.getSize(13)));
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: () {
          _focusNode.unfocus();
          if (isLocked) {
            MyWidget().showDialog(context, rs, content: tr('wantUnlockLesson'), yesFn: () {
              Get.toNamed(MyStrings.routePremiumMain);
            }, hasPremiumTag: true, hasNoBtn: false, yesText: tr('explorePremium'));
          } else {
            if (!isPremiumUser && !lesson.hasOptions && !lesson.adFree) {
              MyWidget().showDialog(context, rs,
                  content: tr('watchRewardAdLesson'),
                  yesFn: () {
                    AdsController().showRewardAd();
                    runLesson(lesson);
                  },
                  hasNoBtn: false,
                  textBtnText: tr('explorePremium'),
                  textBtnFn: () {
                    Get.toNamed(MyStrings.routePremiumMain);
                  });
            } else {
              runLesson(lesson);
            }
          }
        },
        child: Padding(
          padding: EdgeInsets.all(rs.getSize(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      MyWidget().getTextWidget(rs,
                          text: '$index. ${lesson.type}', color: Theme.of(context).primaryColorDark),
                      Obx(
                        () => lessonController.getIsCompleted(lesson.id)
                            ? Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? MyColors.darkPurple
                                      : MyColors.green,
                                  size: rs.getSize(20),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      lesson.tag != null && lesson.tag.toString().isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: MyWidget().getRoundedContainer(
                                  widget: MyWidget().getTextWidget(rs,
                                      text: lesson.tag, color: Theme.of(context).focusColor, size: 13),
                                  bgColor: Theme.of(context).shadowColor,
                                  radius: 30,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3)),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  Row(
                    children: [
                      Row(children: optionIcons),
                      isLocked
                          ? Padding(
                              padding: EdgeInsets.only(left: rs.getSize(8)),
                              child:
                                  Icon(CupertinoIcons.lock_fill, color: Theme.of(context).disabledColor, size: 15),
                            )
                          : const SizedBox.shrink(),
                    ],
                  )
                ],
              ),
              SizedBox(height: rs.getSize(10)),
              MyWidget().getTextWidget(
                rs,
                text: lesson.title[KO],
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: rs.getSize(10)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if(LocalStorage().getBoolFromLocalStorage(key: IS_GRAMMAR_MODE)) {
      modeToggle = [false, true];
    } else {
      modeToggle = [true, false];
    }


    myTutorial = MyTutorial();

    // 최초 앱 (재)설치 후에만 controller.isVisible = true 임.
    // 기존 유저에게도 튜토리얼을 보여주고 싶으면 myTutorial을 전역 변수로 옮기고 build에서 튜토리얼을 실행해야 함.
    isTutorialEnabled = myTutorial!.isTutorialEnabled(myTutorial!.TUTORIAL_COURSE);
    if (isTutorialEnabled) {
      keyCourse = GlobalKey();
      keyTopicMode = GlobalKey();
      keyGrammarMode = GlobalKey();

      List<TargetFocus> targets = [
        myTutorial!.tutorialItem(id: "T1", content: tr('tutorial_course_1')),
        myTutorial!.tutorialItem(id: "T2", keyTarget: keyTopicMode, content: tr('tutorial_course_2')),
        myTutorial!.tutorialItem(id: "T3", keyTarget: keyGrammarMode, content: tr('tutorial_course_3')),
        myTutorial!.tutorialItem(id: "T4", keyTarget: keyCourse, content: tr('tutorial_course_4')),
      ];
      myTutorial!.addTargetsAndRunTutorial(context, targets);
    } else {
      myTutorial = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    rs = ResponsiveSize(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GetBuilder<LessonCourseController>(builder: (_) {
        modeToggle[0] ? courses = controller.courses[0] : courses = controller.courses[1];
        if (searchText.isNotEmpty) {
          searchedLessons = [];
          for (LessonCourse course in courses) {
            for (dynamic l in course.lessons) {
              Lesson lesson = Lesson.fromJson(l as Map<String, dynamic>);
              lesson.courseTitle = course.title['en'];
              if (lesson.title[KO].contains(searchText)) {
                searchedLessons.add(lesson);
              }
            }
          }
        }
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: MyWidget().getTextWidget(
                      rs,
                      text: tr('selectCourse'),
                      size: 20,
                      color: Theme.of(context).primaryColor,
                      isBold: true,
                    ),
                  ),
                  Row(
                    children: [
                      MyWidget().getTextWidget(
                        rs,
                        text: tr('mode'),
                        color: Theme.of(context).primaryColor,
                        isBold: true,
                      ),
                      SizedBox(width: rs.getSize(10)),
                      ToggleButtons(
                        isSelected: modeToggle,
                        onPressed: (int index) {
                          modeToggle[0] = 0 == index;
                          modeToggle[1] = 1 == index;
                          LocalStorage().setBoolToLocalStorage(
                            key: IS_GRAMMAR_MODE,
                            value: index == 1,
                          );
                          controller.update();
                        },
                        constraints: BoxConstraints(minHeight: rs.getSize(30), minWidth: rs.getSize(50)),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        selectedBorderColor: Theme.of(context).primaryColor,
                        selectedColor: Theme.of(context).cardColor,
                        fillColor: Theme.of(context).primaryColor,
                        color: Theme.of(context).primaryColor,
                        children: [
                          Text(
                              key: isTutorialEnabled ? keyTopicMode : null,
                              tr('topic'),
                              style: TextStyle(fontSize: rs.getSize(15))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: rs.getSize(5)),
                            child: Text(
                                key: isTutorialEnabled ? keyGrammarMode : null,
                                tr('grammar'),
                                style: TextStyle(fontSize: rs.getSize(15))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: rs.getSize(10)),
              modeToggle[1]
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: MyWidget().getSearchWidget(
                        context,
                        rs,
                        focusNode: _focusNode,
                        controller: searchController,
                        hint: 'e.g. 아/어요',
                        onChanged: (text) {
                          searchText = searchController.text;
                          controller.update();
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
              Expanded(
                child: modeToggle[1] && searchText.isNotEmpty
                    // Grammar 모드에서 레슨 검색 실행 시
                    ? ListView.builder(
                        itemCount: searchedLessons.length,
                        itemBuilder: (BuildContext context, int index) {
                          return getSearchedGrammarList(index, searchedLessons[index]);
                        },
                      )
                    : ListView.builder(
                        itemCount: courses.length,
                        itemBuilder: (BuildContext context, int index) {
                          LessonCourse course = courses[index];
                          bool isFirst = index == 0;
                          return getLessonCourseList(isFirst: isFirst, lessonCourse: course);
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
