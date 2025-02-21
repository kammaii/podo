import 'dart:convert';
import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podo/common/ads_controller.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_tutorial.dart';
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
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:url_launcher/url_launcher.dart';

class LessonListMain extends StatefulWidget {
  LessonListMain({Key? key, required this.course, required this.isTutorialEnabled}) : super(key: key);

  late LessonCourse course;
  late bool isTutorialEnabled;

  @override
  _LessonListMainState createState() => _LessonListMainState();
}

class _LessonListMainState extends State<LessonListMain> with TickerProviderStateMixin, WidgetsBindingObserver {
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
  late bool isPremiumUser;

  MyTutorial? myTutorial;
  GlobalKey? keyMenu;
  GlobalKey? keyKoreanBites;

  @override
  void initState() {
    super.initState();
    if (User().email == User().admin) {
      isAdmin = true;
    }
    User().status == 2 || User().status == 3 ? isPremiumUser = true : isPremiumUser = false;
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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // 알림 설정, 업데이트 완료 후 복귀했을 때 실행
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      bool permission = settings.authorizationStatus == AuthorizationStatus.authorized;
      if (User().fcmPermission != permission) {
        FirebaseAnalytics analytics = FirebaseAnalytics.instance;
        if (permission) {
          await analytics
              .logEvent(name: 'fcm_permission', parameters: {'status': 'true', 'location': 'noticeBar'});
        } else {
          await analytics
              .logEvent(name: 'fcm_permission', parameters: {'status': 'false', 'location': 'noticeBar'});
        }
        Database().updateDoc(collection: 'Users', docId: User().id, key: 'fcmPermission', value: permission);
        User().fcmPermission = permission;
      }
      if (User().needUpdate) {
        DocumentSnapshot<Map<String, dynamic>> buildNumSnapshot =
            await Database().getDoc(collection: 'BuildNumber', docId: 'latest');
        if (buildNumSnapshot.exists) {
          int lastBuildNum = buildNumSnapshot.data()!['buildNumber'];
          if (User().buildNumber! >= lastBuildNum) {
            User().needUpdate = false;
          }
        }
      }

      lessonController.update();
    }
  }

  runLesson(Lesson lesson) async {
    LocalStorage().setLessonScrollPosition(scrollController.offset);

    await FirebaseAnalytics.instance.logSelectContent(
        contentType: 'lesson',
        itemId: lesson.title[KO],
        parameters: {'course_title': course.title['en'], 'course_mode': course.isTopicMode ? 'Topic' : 'Grammar'});
    if (!lesson.hasOptions) {
      Get.toNamed(MyStrings.routeLessonFrame, arguments: lesson);
    } else {
      Get.toNamed(MyStrings.routeLessonSummaryMain, arguments: lesson);
    }
  }

  Widget lessonListWidget(int index) {
    late Lesson lesson;

    lesson = Lesson.fromJson(course.lessons[index] as Map<String, dynamic>);
    bool isReleased = lesson.isReleased;

    isAdmin ? isReleased = true : null;

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

    return isReleased
        ? Column(
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
                                          child: Icon(CupertinoIcons.lock_fill,
                                              color: Theme.of(context).disabledColor, size: 15),
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
      leading: IconButton(
        key: keyMenu,
        icon: Icon(Icons.menu, size: rs.getSize(25)),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          courseController.setVisibility(true);
          Future.delayed(const Duration(milliseconds: 500), () {
            scrollController.jumpTo(0);
          });
        },
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

  Widget floatingBtn({
    required String tag,
    required String route,
    required Color btnColor,
    required IconData btnIcon,
    required String title,
    required Color titleColor,
    String? id,
    GlobalKey? key,
  }) {
    return Column(
      key: key,
      children: [
        SizedBox(
          width: rs.getSize(56),
          height: rs.getSize(56),
          child: FloatingActionButton(
            heroTag: tag,
            onPressed: () {
              Get.toNamed(route, arguments: id);
            },
            backgroundColor: btnColor,
            child: Icon(btnIcon, size: rs.getSize(30)),
          ),
        ),
        SizedBox(height: rs.getSize(5)),
        MyWidget().getTextWidget(
          rs,
          text: title,
          color: titleColor,
          isBold: true,
        ),
        SizedBox(height: rs.getSize(20)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    course = widget.course;
    rs = ResponsiveSize(context);

    // LessonCourse 에서 튜토리얼을 보고 넘어왔을 경우에만 widget.isTutorialEnabled = true.
    if (widget.isTutorialEnabled) {
      myTutorial = MyTutorial();
      bool isTutorialEnabled =
          myTutorial!.isTutorialEnabled(myTutorial!.TUTORIAL_LESSON_LIST); // 사실 필요없는 코드지만 한번 더 체크
      if (isTutorialEnabled) {
        keyMenu = GlobalKey();
        keyKoreanBites = GlobalKey();
        List<TargetFocus> targets = [
          myTutorial!.tutorialItem(id: "T1", keyTarget: keyMenu, content: tr('tutorial_lesson_list_1')),
          myTutorial!.tutorialItem(id: "T2", keyTarget: keyKoreanBites, content: tr('tutorial_lesson_list_2'), isAlignBottom: false),
          myTutorial!.tutorialItem(id: "T3", content: tr('tutorial_lesson_list_3')),
        ];
        myTutorial!.addTargetsAndRunTutorial(context, targets);
      } else {
        myTutorial = null;
      }
    }

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

    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          course.hasWorkbook
              ? floatingBtn(
                  tag: 'workbookBtn',
                  route: MyStrings.routeWorkbookMain,
                  btnColor: MyColors.pinkDark,
                  btnIcon: FontAwesomeIcons.solidFileAudio,
                  title: tr('workbook'),
                  titleColor: MyColors.wine,
                  id: course.id,
                )
              : const SizedBox.shrink(),
          floatingBtn(
              key: keyKoreanBites,
              tag: 'koreanBitesBtn',
              route: MyStrings.routeKoreanBiteListMain,
              btnColor: Theme.of(context).primaryColor,
              btnIcon: Icons.cookie,
              title: 'Korean Bites',
              titleColor: Theme.of(context).primaryColor),
        ],
      ),
      body: Column(
        children: [
          GetBuilder<LessonController>(
            builder: (_) {
              return Column(
                children: [
                  Visibility(
                      visible: !User().fcmPermission,
                      child: GestureDetector(
                        onTap: () {
                          openAppSettings();
                        },
                        child: SizedBox(
                          height: rs.getSize(30),
                          child: Marquee(
                            text: '${tr('fcmRequest')}   ${tr('clickHere')}',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'EnglishFont'),
                            blankSpace: 100,
                          ),
                        ),
                      )),
                  Visibility(
                      visible: User().fcmPermission && User().needUpdate,
                      child: GestureDetector(
                        onTap: () async {
                          Uri androidUrl = Uri.parse(
                              'https://play.google.com/store/apps/details?id=net.awesomekorean.newpodo&hl=en_US');
                          Uri iosUrl = Uri.parse('https://apps.apple.com/kr/app/podo-korean/id6451487431');
                          if (io.Platform.isAndroid) {
                            if (await canLaunchUrl(androidUrl)) {
                              await launchUrl(androidUrl);
                            }
                          } else if (io.Platform.isIOS) {
                            if (await canLaunchUrl(iosUrl)) {
                              await launchUrl(iosUrl);
                            }
                          }
                        },
                        child: SizedBox(
                          height: rs.getSize(30),
                          child: Marquee(
                            text: '${tr('updateRequest')}   ${tr('clickHere')}',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'EnglishFont'),
                            blankSpace: 100,
                          ),
                        ),
                      )),
                  Visibility(
                    visible: PodoMessage().isActive,
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
                                        ? Theme.of(context).brightness == Brightness.dark
                                            ? MyColors.darkPurple
                                            : MyColors.green
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
                  ),
                ],
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
    );
  }
}
