import 'dart:convert';
import 'package:podo/fcm_controller.dart';
import 'package:podo/screens/korean_bite/korean_bite.dart';
import 'package:podo/values/my_strings.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/common/my_tutorial.dart';
import 'package:podo/screens/flashcard/flashcard_main.dart';
import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:podo/screens/lesson/lesson_course_controller.dart';
import 'package:podo/screens/lesson/lesson_list_main.dart';
import 'package:podo/screens/loading_controller.dart';
import 'package:podo/screens/my_page/my_page.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/screens/reading/reading_list_main.dart';
import 'package:podo/screens/writing/writing_my_list.dart';
import 'package:podo/values/my_colors.dart';

import '../common/database.dart';

class MainFrame extends StatefulWidget {
  const MainFrame({Key? key}) : super(key: key);

  @override
  _MainFrameState createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> with SingleTickerProviderStateMixin {
  List<bool> modeToggle = [true, false];
  final LESSON_COURSES = 'LessonCourses';
  final ORDER_ID = 'orderId';
  final IS_BEGINNER_MODE = 'isBeginnerMode';
  String setLanguage = User().language;
  late AnimationController animationController;
  late Animation<Offset> animationOffset;
  final controller = Get.find<LessonCourseController>();
  List<LessonCourse> courses = [];
  late PersistentTabController _controller;
  late ResponsiveSize rs;
  int? trialLeftDate;
  bool showTrialLeftDate = false;
  int controllerIndex = 0;

  MyTutorial? myTutorial;
  bool isTutorialEnabled = false;
  bool shouldRunLessonListTutorial = false; // 레슨 코스에서 튜토리얼이 진행 되고난 후 코스를 선택하면 true가 됨.
  // 튜토리얼 포커스용 키
  GlobalKey? keyTopicMode;
  GlobalKey? keyGrammarMode;
  GlobalKey? keyCourse;

  List<Widget> _buildScreens() {
    LessonCourse? course = LocalStorage().getLessonCourse();
    return [
      course != null ? LessonListMain(course: course, isTutorialEnabled: shouldRunLessonListTutorial) : const SizedBox.shrink(),
      ReadingListMain(),
      WritingMyList(),
      const FlashCardMain(),
      const MyPage(),
    ];
  }

  PersistentBottomNavBarItem _navBarItem(String title, Icon icon) {
    return PersistentBottomNavBarItem(
      icon: icon,
      title: title,
      activeColorPrimary: Theme.of(context).primaryColor,
      inactiveColorPrimary: Theme.of(context).disabledColor,
      iconSize: rs.getSize(23),
    );
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      _navBarItem(tr('lessons'), const Icon(FontAwesomeIcons.chalkboard)),
      _navBarItem(tr('reading'), const Icon(FontAwesomeIcons.book)),
      _navBarItem(tr('writing'), const Icon(FontAwesomeIcons.pen)),
      _navBarItem(tr('flashcard'), const Icon(FontAwesomeIcons.solidStar)),
      _navBarItem(tr('myPage'), const Icon(Icons.settings)),
    ];
  }

  setCourseVisibility() {
    if (controller.isVisible) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
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
              controller.setVisibility(false);
              if(isTutorialEnabled) {
                shouldRunLessonListTutorial = true;
              }
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

  @override
  void initState() {
    super.initState();
    Get.put(LoadingController());
    _controller = PersistentTabController(initialIndex: 0);
    _controller.addListener(() {
      controllerIndex = _controller.index;
      controller.update();
    });
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    animationOffset = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(animationController);
    if (User().status == 3) {
      trialLeftDate = User().trialEnd!.difference(DateTime.now()).inDays;
      showTrialLeftDate = true;
    }
    if (!LocalStorage().hasWelcome) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LocalStorage().hasWelcome = true;
        MyWidget().showSnackbarWithPodo(rs, title: tr('welcome'), content: tr('welcomeMessage'));
        if (User().isConvertedBasic) {
          Get.dialog(
              AlertDialog(
                title: Image.asset('assets/images/podo.png', width: rs.getSize(50), height: rs.getSize(50)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyWidget().getTextWidget(rs, text: tr('premiumEnd'), isTextAlignCenter: true, size: 16),
                    const SizedBox(height: 10),
                    MyWidget().getTextWidget(rs,
                        text: tr('getDiscount'),
                        isTextAlignCenter: true,
                        color: MyColors.purple,
                        isBold: true,
                        size: 18),
                  ],
                ),
                actionsAlignment: MainAxisAlignment.center,
                actionsPadding: EdgeInsets.only(
                    left: rs.getSize(20), right: rs.getSize(20), bottom: rs.getSize(20), top: rs.getSize(10)),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              side: const BorderSide(color: MyColors.purple, width: 1),
                              backgroundColor: MyColors.purple),
                          onPressed: () async {
                            await FirebaseAnalytics.instance.logEvent(name: 'click_trial_end');
                            Get.back();
                            Get.toNamed(MyStrings.routePremiumMain);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: rs.getSize(13)),
                            child: Text(tr('explorePremium'),
                                style: TextStyle(color: Colors.white, fontSize: rs.getSize(15))),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              barrierDismissible: false);
        }
      });
    }

    myTutorial = MyTutorial();

    // 최초 앱 (재)설치 후에만 controller.isVisible = true 임.
    // 기존 유저에게도 튜토리얼을 보여주고 싶으면 myTutorial을 전역 변수로 옮기고 build에서 튜토리얼을 실행해야 함.
    isTutorialEnabled = myTutorial!.isTutorialEnabled(myTutorial!.TUTORIAL_COURSE) && controller.isVisible;
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(FcmController.pendingFcmData != null) {
        Map<String,dynamic> fcmData = FcmController.pendingFcmData!;
        String? tag = fcmData['tag'];
        if(tag != null) {
          switch (tag) {
            case 'koreanBite':
              String koreanBiteId = fcmData['koreanBiteId']!;
              await Database().getDoc(collection: 'KoreanBites', docId: koreanBiteId).then((snapshot) async {
                KoreanBite bite = KoreanBite.fromJson(snapshot.data() as Map<String, dynamic>);
                await FirebaseAnalytics.instance.logEvent(name: 'fcm_click_koreanbite', parameters: {'title': bite.title['ko']});
                Get.toNamed(MyStrings.routeKoreanBiteListMain, arguments: bite);
              });
              break;

            case 'writing' :
              _controller.index = 2;
              break;
          }
          FcmController.pendingFcmData == null;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light, // 상태바 아이콘 색상
      statusBarColor: Theme.of(context).canvasColor,
    ));

    rs = ResponsiveSize(context);
    return GetBuilder<LessonCourseController>(
      builder: (_) {
        modeToggle[0] ? courses = controller.courses[0] : courses = controller.courses[1];
        setCourseVisibility();

        return WillPopScope(
          onWillPop: () async {
            bool isExit = false;
            await Get.dialog(AlertDialog(
              title: MyWidget().getTextWidget(rs, text: tr('exitApp')),
              actions: [
                TextButton(
                    onPressed: () {
                      SystemNavigator.pop();
                      isExit = true;
                    },
                    child: MyWidget().getTextWidget(rs, text: tr('yes'), color: MyColors.navy)),
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: MyWidget().getTextWidget(rs, text: tr('no'), color: MyColors.purple)),
              ],
            ));
            return isExit;
          },
          child: Scaffold(
            body: Stack(
              children: [
                PersistentTabView(
                  context,
                  controller: _controller,
                  screens: _buildScreens(),
                  items: _navBarsItems(),
                  confineToSafeArea: true,
                  backgroundColor: Theme.of(context).cardColor,
                  // Default is Colors.white.
                  handleAndroidBackButtonPress: true,
                  // Default is true.
                  resizeToAvoidBottomInset: true,
                  // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
                  stateManagement: true,
                  // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
                  decoration: NavBarDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    colorBehindNavBar: Theme.of(context).cardColor,
                  ),
                  navBarStyle: NavBarStyle.style3,
                  // Choose the nav bar style with this property.
                  navBarHeight: rs.getSize(55),
                ),
                Offstage(
                  offstage: !controller.isVisible,
                  child: const Opacity(opacity: 0, child: ModalBarrier(dismissible: false, color: Colors.white)),
                ),
                Positioned(
                  bottom: 0,
                  child: SlideTransition(
                    position: animationOffset,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: rs.getSize(10), right: rs.getSize(10), bottom: rs.getSize(10), top: rs.getSize(50)),
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
                                          controller.update();
                                        },
                                        constraints:
                                            BoxConstraints(minHeight: rs.getSize(30), minWidth: rs.getSize(50)),
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
                              Expanded(
                                child: ListView.builder(
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
                        ),
                      ),
                    ),
                  ),
                ),
                showTrialLeftDate && _controller.index == 0
                    ? Positioned(
                        right: rs.getSize(10),
                        top: rs.getSize(90),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            backgroundColor: Colors.transparent,
                          ),
                          onPressed: () {
                            Get.toNamed('/premiumMain', arguments: trialLeftDate);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: rs.getSize(5), horizontal: rs.getSize(20)),
                            decoration: BoxDecoration(
                                color: MyColors.green,
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              children: [
                                MyWidget().getTextWidget(rs,
                                    text: '$trialLeftDate ${trialLeftDate! > 1 ? 'days' : 'day'} Left in Trial',
                                    color: Colors.white),
                                MyWidget().getTextWidget(rs,
                                    text: tr('explorePremium'), color: Colors.white, isBold: true, hasUnderline: true),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }
}
