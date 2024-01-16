import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/ads_controller.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/lesson/lesson.dart';
import 'package:podo/screens/lesson/lesson_controller.dart';
import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:podo/screens/lesson/lesson_course_controller.dart';
import 'package:podo/screens/message/podo_message.dart';
import 'package:podo/screens/message/podo_message_controller.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  final cardBorderRadius = 8.0;
  late AnimationController animationController;
  late Animation<double> animation;
  final courseController = Get.find<LessonCourseController>();
  final lessonController = Get.put(LessonController());
  bool isAdmin = false;
  late ResponsiveSize rs;

  @override
  void initState() {
    super.initState();
    if (User().email == User().admin) {
      isAdmin = true;
    }
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.jumpTo(LocalStorage().getLessonScrollPosition());
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  runLesson(Lesson lesson) async {
    LocalStorage().setLessonScrollPosition(scrollController.offset);
    await FirebaseAnalytics.instance.logSelectContent(contentType: 'lesson', itemId: lesson.id);
    if (!lesson.hasOptions) {
      Get.toNamed(MyStrings.routeLessonFrame, arguments: lesson);
    } else {
      Get.toNamed(MyStrings.routeLessonSummaryMain, arguments: lesson);
    }
  }

  Widget lessonListWidget(int index) {
    late Lesson lesson;
    bool isReleased = true;

    lesson = Lesson.fromJson(course.lessons[index] as Map<String, dynamic>);
    if (!isAdmin && !lesson.isReleased) {
      isReleased = false;
    }
    bool isLocked = false;
    if (User().status == 1 && !lesson.isFree) {
      isLocked = true;
    }

    return isReleased
        ? Theme(
            data: Theme.of(context).copyWith(highlightColor: MyColors.navyLight),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rs.getSize(10)),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardBorderRadius),
                    ),
                    color: Theme.of(context).cardColor,
                    child: InkWell(
                      onTap: () {
                        if (isLocked) {
                          MyWidget().showDialog(context, rs, content: tr('wantUnlockLesson'), yesFn: () {
                            Get.toNamed(MyStrings.routePremiumMain);
                          }, hasPremiumTag: true, hasNoBtn: false, yesText: tr('explorePremium'));
                        } else {
                          if (User().status == 1 && !lesson.hasOptions) {
                            MyWidget().showDialog(context, rs, content: tr('watchRewardAdLesson'), yesFn: () {
                              AdsController().showRewardAd();
                              runLesson(lesson);
                            }, hasNoBtn: false, hasTextBtn: true);
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
                                                color: Theme.of(context).highlightColor,
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
                                                    text: lesson.tag,
                                                    color: Theme.of(context).focusColor,
                                                    size: 13),
                                                bgColor: Theme.of(context).shadowColor,
                                                radius: 30,
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3)),
                                          )
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                                isLocked
                                    ? Icon(CupertinoIcons.lock_fill,
                                        color: Theme.of(context).disabledColor, size: 15)
                                    : const SizedBox.shrink()
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
                            course.isTopicMode
                                ? MyWidget().getTextWidget(rs,
                                    text: lesson.title[language], color: Theme.of(context).disabledColor)
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  sliverAppBar() {
    int lessonCount = 0;
    for (dynamic lesson in course.lessons) {
      if (lesson is Map) {
        Lesson l = Lesson.fromJson(lesson as Map<String, dynamic>);
        if (l.isReleased) {
          lessonCount++;
        }
      }
    }
    return SliverAppBar(
      leading: Theme(
        data: Theme.of(context).copyWith(highlightColor: MyColors.navyLight),
        child: IconButton(
          icon: Icon(Icons.menu, size: rs.getSize(25)),
          color: Theme.of(context).primaryColor,
          onPressed: () {
            courseController.setVisibility(true);
            Future.delayed(const Duration(milliseconds: 500), () {
              scrollController.jumpTo(0);
            });
          },
        ),
      ),
      expandedHeight: rs.getSize(sliverAppBarHeight),
      collapsedHeight: rs.getSize(60),
      pinned: true,
      stretch: true,
      title: MyWidget().getTextWidget(
        rs,
        text: '${course.title[language]} ($lessonCount ${tr('lessons')})',
        size: 18,
        color: Theme.of(context).primaryColor,
        isBold: true,
      ),
      flexibleSpace: Stack(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          course.image != null
              ? Positioned(
                  top: -30,
                  right: -30,
                  child: FadeTransition(
                    opacity: animation,
                    child: course.image != null
                        ? Image.memory(base64Decode(course.image!), gaplessPlayback: true, width: rs.getSize(200))
                        : const SizedBox.shrink(),
                  ),
                )
              : const SizedBox.shrink(),
          Obx(
            () => LinearProgressIndicator(
              value: lessonController.isCompleted.values.isEmpty
                  ? 0
                  : lessonController.isCompleted.values.where((value) => value == true).length /
                      lessonController.isCompleted.length,
              color: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).cardColor,
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
      padding: EdgeInsets.only(top: rs.getSize(20), bottom: rs.getSize(50)),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return lessonListWidget(index);
          },
          childCount: course.lessons.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    course = widget.course;
    rs = ResponsiveSize(context);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Map<String, bool> map = {};
      for (dynamic lessonMap in course.lessons) {
        if (lessonMap is Map) {
          Lesson lesson = Lesson.fromJson(lessonMap as Map<String, dynamic>);
          map[lesson.id] = LocalStorage().hasHistory(itemId: lesson.id);
        }
      }
      lessonController.isCompleted.value = map;
    });

    final cloudController = Get.put(PodoMessageController());
    if (PodoMessage().id != null) {
      cloudController.setPodoMsgBtn();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await courseController.loadCourses();
        await PodoMessage().getPodoMessage();
        setState(() {});
      },
      child: Scaffold(
        floatingActionButton: course.hasWorkbook
            ? Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: rs.getSize(56),
                    height: rs.getSize(56),
                    child: FloatingActionButton(
                      heroTag: 'workbookBtn',
                      onPressed: () {
                        Get.toNamed(MyStrings.routeWorkbookMain, arguments: course.id);
                      },
                      backgroundColor: MyColors.pinkDark,
                      child: Icon(FontAwesomeIcons.solidFileAudio, size: rs.getSize(30)),
                    ),
                  ),
                  SizedBox(height: rs.getSize(5)),
                  MyWidget().getTextWidget(
                    rs,
                    text: 'Workbook',
                    color: MyColors.wine,
                    isBold: true,
                  ),
                  SizedBox(height: rs.getSize(20)),
                ],
              )
            : const SizedBox.shrink(),
        body: Column(
          children: [
            GetBuilder<LessonController>(
              builder: (_) {
                return Visibility(
                  visible: User().status != 0 && PodoMessage().isActive,
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(MyStrings.routePodoMessageMain);
                    },
                    child: Container(
                      color: Theme.of(context).primaryColorLight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: rs.getSize(10), vertical: rs.getSize(8)),
                        child: Row(
                          children: [
                            Image.asset('assets/images/podo.png', height: rs.getSize(40), width: rs.getSize(40)),
                            SizedBox(width: rs.getSize(15)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyWidget().getTextWidget(rs,
                                      text: PodoMessage().title?[KO] ?? '',
                                      isKorean: true,
                                      size: 18,
                                      color: Theme.of(context).primaryColor,
                                      maxLine: 1),
                                  SizedBox(height: rs.getSize(5)),
                                  MyWidget().getTextWidget(rs,
                                      text: PodoMessage().title?[User().language] ?? '',
                                      color: Theme.of(context).disabledColor,
                                      size: 13,
                                      maxLine: 1),
                                ],
                              ),
                            ),
                            SizedBox(width: rs.getSize(10)),
                            Center(
                              child: Obx(
                                () => MyWidget().getRoundedContainer(
                                  radius: 30,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: rs.getSize(10), vertical: rs.getSize(5)),
                                  bgColor: cloudController.podoMsgBtnActive.value
                                      ? Theme.of(context).highlightColor
                                      : Theme.of(context).disabledColor,
                                  widget: MyWidget().getTextWidget(rs,
                                      text: cloudController.podoMsgBtnText,
                                      color: Theme.of(context).cardColor,
                                      size: 13),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
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
    );
  }
}
