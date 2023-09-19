import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
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

class MainFrame extends StatefulWidget {
  const MainFrame({Key? key}) : super(key: key);

  @override
  _MainFrameState createState() => _MainFrameState();
}

List<Widget> _buildScreens() {
  LessonCourse? course = LocalStorage().getLessonCourse();
  return [
    course != null ? LessonListMain(course: course) : const SizedBox.shrink(),
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
    activeColorPrimary: MyColors.purple,
    inactiveColorPrimary: MyColors.grey,
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

  setCourseVisibility() {
    if (controller.isVisible) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  Widget getLessonCourseList({required LessonCourse lessonCourse}) {
    return Card(
      child: InkWell(
        onTap: () {
          LocalStorage().setLessonCourse(lessonCourse);
          controller.setVisibility(false);
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  lessonCourse.image != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Image.memory(base64Decode(lessonCourse.image!), height: 80, width: 80),
                        )
                      : const SizedBox.shrink(),
                  Expanded(
                    child: MyWidget().getTextWidget(
                      text: lessonCourse.title[setLanguage],
                      size: modeToggle[0] ? 25 : 20,
                      color: MyColors.purple,
                      isBold: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: modeToggle[0] ? 20 : 0),
              modeToggle[0]
                  ? MyWidget().getTextWidget(
                      text: lessonCourse.description[setLanguage],
                      size: 15,
                      color: MyColors.grey,
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Get.put(LoadingController());
    _controller = PersistentTabController(initialIndex: 0);
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    animationOffset = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(animationController);
    if (!LocalStorage().hasWelcome) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LocalStorage().hasWelcome = true;
        MyWidget().showSnackbarWithPodo(title: tr('welcome'), content: tr('welcomeMessage'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LessonCourseController>(
      builder: (_) {
        modeToggle[0] ? courses = controller.courses[0] : courses = controller.courses[1];
        setCourseVisibility();

        return WillPopScope(
          onWillPop: () async {
            bool isExit = false;
            await Get.dialog(AlertDialog(
              title: Text(tr('exitApp')),
              actions: [
                TextButton(
                    onPressed: () {
                      SystemNavigator.pop();
                      isExit = true;
                    },
                    child: Text(tr('yes'), style: const TextStyle(color: MyColors.navy))),
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(tr('no'), style: const TextStyle(color: MyColors.purple))),
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
                  confineInSafeArea: true,
                  backgroundColor: Colors.white,
                  // Default is Colors.white.
                  handleAndroidBackButtonPress: true,
                  // Default is true.
                  resizeToAvoidBottomInset: true,
                  // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
                  stateManagement: true,
                  // Default is true.
                  hideNavigationBarWhenKeyboardShows: true,
                  // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
                  decoration: NavBarDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    colorBehindNavBar: Colors.white,
                  ),
                  popAllScreensOnTapOfSelectedTab: true,
                  popActionScreens: PopActionScreensType.all,
                  itemAnimationProperties: const ItemAnimationProperties(
                    // Navigation Bar's items animation properties.
                    duration: Duration(milliseconds: 200),
                    curve: Curves.ease,
                  ),
                  screenTransitionAnimation: const ScreenTransitionAnimation(
                    // Screen transition animation on change of selected tab.
                    animateTabTransition: true,
                    curve: Curves.ease,
                    duration: Duration(milliseconds: 200),
                  ),
                  navBarStyle: NavBarStyle.style3, // Choose the nav bar style with this property.
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
                      child: SafeArea(
                        child: Container(
                          color: MyColors.purpleLight,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: MyWidget().getTextWidget(
                                        text: tr('selectCourse'),
                                        size: 20,
                                        color: MyColors.purple,
                                        isBold: true,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        MyWidget().getTextWidget(
                                          text: tr('mode'),
                                          size: 13,
                                          color: MyColors.purple,
                                          isBold: true,
                                        ),
                                        const SizedBox(width: 5),
                                        ToggleButtons(
                                          isSelected: modeToggle,
                                          onPressed: (int index) {
                                            modeToggle[0] = 0 == index;
                                            modeToggle[1] = 1 == index;
                                            controller.update();
                                          },
                                          constraints: const BoxConstraints(minHeight: 35, minWidth: 45),
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          selectedBorderColor: MyColors.purple,
                                          selectedColor: Colors.white,
                                          fillColor: MyColors.purple,
                                          color: MyColors.purple,
                                          children: [
                                            Text(tr('topic')),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                              child: Text(tr('grammar')),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: courses.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      LessonCourse course = courses[index];
                                      return getLessonCourseList(lessonCourse: course);
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
