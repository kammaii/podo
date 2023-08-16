import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/lesson/lesson.dart';
import 'package:podo/screens/lesson/lesson_controller.dart';
import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:podo/screens/lesson/lesson_course_controller.dart';
import 'package:podo/screens/message/podo_message.dart';
import 'package:podo/screens/message/podo_message_controller.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class LessonListMain extends StatefulWidget {
  LessonListMain({Key? key, required this.course}) : super(key: key);

  late LessonCourse course;

  @override
  _LessonListMainState createState() => _LessonListMainState();
}

class _LessonListMainState extends State<LessonListMain> with TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  double sliverAppBarHeight = 150.0;
  double sliverAppBarStretchOffset = 100.0;
  late LessonCourse course;
  String language = User().language;
  final KO = 'ko';
  final LESSON = 'Lesson';
  int lessonIndex = -1;
  final cardBorderRadius = 8.0;
  late AnimationController animationController;
  late Animation<double> animation;
  final courseController = Get.find<LessonCourseController>();
  final lessonController = Get.put(LessonController());
  List<Lesson> lessons = [];

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    ));
    scrollController.addListener(() => setState(() {
          if (scrollController.offset <= 100) {
            if (animationController.value == 1) {
              animationController.reverse();
            }
          } else {
            if (animationController.value == 0) {
              animationController.forward();
            }
          }
        }));
  }

  Widget lessonListWidget(dynamic lessonMap) {
    late Lesson lesson;
    bool isReleased = true;

    if (lessonMap is Map) {
      lesson = Lesson.fromJson(lessonMap as Map<String, dynamic>);
      if (!lesson.isReleased) {
        isReleased = false;
      }
      if (lesson.type == LESSON) {
        lessonIndex++;
      }
    }

    return isReleased
        ? Column(
            children: [
              if (lessonMap is String)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 5),
                  child: MyWidget().getTextWidget(
                    text: lessonMap,
                    size: 25,
                    color: MyColors.navyLight,
                  ),
                )
              else
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(cardBorderRadius),
                        ),
                        color: Colors.white,
                        child: InkWell(
                          onTap: () async {
                            //todo: await FirebaseAnalytics.instance.logSelectContent(contentType: 'lesson', itemId: lesson.id);
                            if (course.id == courseController.hangulCourseId) {
                              lessonController.isHangulLesson = true;
                              Get.toNamed(MyStrings.routeLessonFrame, arguments: lesson);
                            } else {
                              lessonController.isHangulLesson = false;
                              Get.toNamed(MyStrings.routeLessonSummaryMain, arguments: lesson);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    MyWidget().getTextWidget(
                                      text: lesson.type == LESSON ? '$LESSON $lessonIndex' : lesson.type,
                                      color: MyColors.grey,
                                    ),
                                    const SizedBox(width: 10),
                                    Obx(
                                      () => lessonController.isCompleted[lesson.id]
                                          ? const Icon(
                                              Icons.check_circle,
                                              color: MyColors.green,
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                MyWidget().getTextWidget(
                                  text: lesson.title[KO],
                                  size: 20,
                                  color: MyColors.navy,
                                ),
                                const SizedBox(height: 10),
                                MyWidget().getTextWidget(
                                  text: lesson.title[language],
                                  color: MyColors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    lesson.tag != null
                        ? Positioned(
                            top: 4,
                            right: 14,
                            child: Container(
                                decoration: BoxDecoration(
                                  color: MyColors.pink,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(cardBorderRadius),
                                    bottomLeft: Radius.circular(cardBorderRadius),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                child: MyWidget().getTextWidget(text: lesson.tag, color: MyColors.red)))
                        : const SizedBox.shrink(),
                  ],
                ),
            ],
          )
        : const SizedBox.shrink();
  }

  sliverAppBar() {
    int lessonCount = 0;
    for (dynamic lesson in course.lessons) {
      if (lesson is Map) {
        lessonCount++;
      }
    }
    return SliverAppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        color: MyColors.purple,
        onPressed: () {
          courseController.setVisibility(true);
        },
      ),
      expandedHeight: sliverAppBarHeight,
      collapsedHeight: 60,
      pinned: true,
      stretch: true,
      title: MyWidget().getTextWidget(
        text: '${course.title[language]} ($lessonCount ${tr('lessons')})',
        size: 18,
        color: MyColors.purple,
        isBold: true,
      ),
      flexibleSpace: Stack(
        children: [
          Container(
            color: MyColors.purpleLight,
          ),
          course.image != null
              ? Positioned(
                  top: -30,
                  right: -30,
                  child: FadeTransition(
                    opacity: animation,
                    child: course.image != null
                        ? Image.memory(base64Decode(course.image!), gaplessPlayback: true, width: 200)
                        : const SizedBox.shrink(),
                  ),
                )
              : const SizedBox.shrink(),
          Obx(
            () => LinearProgressIndicator(
              value: lessonController.isCompleted.values.where((value) => value == true).length /
                  lessonController.isCompleted.length,
              color: MyColors.purple,
              backgroundColor: MyColors.purpleLight,
            ),
          )
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(10.0),
        child: Text(''),
      ),
    );
  }

  sliverList() {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 20.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return lessonListWidget(course.lessons[index]);
          },
          childCount: course.lessons.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    course = widget.course;
    Map<String, bool> map = {};
    for (dynamic lessonMap in course.lessons) {
      if (lessonMap is Map) {
        Lesson lesson = Lesson.fromJson(lessonMap as Map<String, dynamic>);
        lessons.add(lesson);
        map[lesson.id] = LocalStorage().hasHistory(itemId: lesson.id);
      }
    }
    lessonController.isCompleted.value = map;
    lessonIndex = -1;
    final cloudController = Get.put(PodoMessageController());
    if (PodoMessage().id != null) {
      bool hasReplied = LocalStorage().hasHistory(itemId: PodoMessage().id!);
      cloudController.setHasReplied(hasReplied);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await courseController.loadCourses();
        await PodoMessage().getPodoMessage();
        setState(() {});
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Visibility(
                visible: User().status != 0 && PodoMessage().isActive,
                child: InkWell(
                  onTap: () {
                    Get.toNamed(MyStrings.routePodoMessageMain);
                  },
                  child: Container(
                    color: MyColors.navyLight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          Image.asset('assets/images/podo.png', height: 40, width: 40),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyWidget().getTextWidget(
                                    text: PodoMessage().title?[KO] ?? '',
                                    isKorean: true,
                                    size: 18,
                                    color: MyColors.purple,
                                    maxLine: 1),
                                const SizedBox(height: 5),
                                MyWidget().getTextWidget(
                                    text: PodoMessage().title?[User().language] ?? '',
                                    color: MyColors.grey,
                                    size: 13,
                                    maxLine: 1),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Center(
                            child: Obx(
                              () => MyWidget().getRoundedContainer(
                                radius: 30,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                bgColor: cloudController.hasReplied.value ? MyColors.grey : MyColors.green,
                                widget: MyWidget().getTextWidget(
                                    text: cloudController.hasReplied.value ? tr('replied') : tr('replyPodo'),
                                    color: Colors.white,
                                    size: 13),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: MyColors.purpleLight,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: scrollController,
                    slivers: [
                      sliverAppBar(),
                      sliverList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
