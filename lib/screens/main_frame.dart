import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:podo/screens/flashcard/flashcard_main.dart';
import 'package:podo/screens/lesson/lesson_course_main.dart';
import 'package:podo/screens/profile/profile.dart';
import 'package:podo/screens/reading/reading_main.dart';
import 'package:podo/values/my_colors.dart';


class MainFrame extends StatefulWidget {
  const MainFrame({Key? key}) : super(key: key);

  @override
  _MainFrameState createState() => _MainFrameState();
}

List<Widget> _buildScreens() {
  return [
    LessonCourseMain(),
    ReadingMain(),
    const FlashCardMain(),
    const Profile(),
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
    _navBarItem('Lessons', const Icon(FontAwesomeIcons.chalkboard)),
    _navBarItem('Reading', const Icon(FontAwesomeIcons.book)),
    _navBarItem('Flashcards', const Icon(Icons.star_rounded)),
    _navBarItem('Settings', const Icon(Icons.settings)),
  ];
}

class _MainFrameState extends State<MainFrame> {
  @override
  Widget build(BuildContext context) {
    PersistentTabController _controller;
    _controller = PersistentTabController(initialIndex: 0);

    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties( // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation( // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style3, // Choose the nav bar style with this property.
    );
  }
}
