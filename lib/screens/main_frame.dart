import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/fcm_controller.dart';
import 'package:podo/screens/flashcard/flashcard_main.dart';
import 'package:podo/screens/korean_bite/korean_bite.dart';
import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:podo/screens/lesson/lesson_course_controller.dart';
import 'package:podo/screens/lesson/lesson_list_main.dart';
import 'package:podo/screens/loading_controller.dart';
import 'package:podo/screens/my_page/my_page.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/screens/reading/reading_list_main.dart';
import 'package:podo/screens/writing/writing_my_list.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import '../common/database.dart';

class MainFrame extends StatefulWidget {
  const MainFrame({Key? key}) : super(key: key);
  static bool shouldRunLessonListTutorial = false; // 레슨 코스에서 튜토리얼이 진행 되고난 후 코스를 선택하면 true가 됨.


  @override
  _MainFrameState createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> with SingleTickerProviderStateMixin {
  final controller = Get.find<LessonCourseController>();
  late PersistentTabController _controller;
  late ResponsiveSize rs;
  int? trialLeftDate;
  bool showTrialLeftDate = false;
  int controllerIndex = 0;


  List<Widget> _buildScreens() {
    LessonCourse? course = LocalStorage().getLessonCourse();
    return [
      course != null
          ? LessonListMain(course: course, isTutorialEnabled: MainFrame.shouldRunLessonListTutorial)
          : const SizedBox.shrink(),
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

  @override
  void initState() {
    super.initState();
    Get.put(LoadingController());
    _controller = PersistentTabController(initialIndex: 0);
    _controller.addListener(() {
      controllerIndex = _controller.index;
      controller.update();
    });

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (FcmController.pendingFcmData != null) {
        Map<String, dynamic> fcmData = FcmController.pendingFcmData!;
        String? tag = fcmData['tag'];
        if (tag != null) {
          switch (tag) {
            case 'koreanBite':
              String koreanBiteId = fcmData['koreanBiteId']!;
              await Database().getDoc(collection: 'KoreanBites', docId: koreanBiteId).then((snapshot) async {
                KoreanBite bite = KoreanBite.fromJson(snapshot.data() as Map<String, dynamic>);
                await FirebaseAnalytics.instance
                    .logEvent(name: 'fcm_click_koreanbite', parameters: {'title': bite.title['ko']});
                Get.toNamed(MyStrings.routeKoreanBiteListMain, arguments: bite);
              });
              break;

            case 'writing':
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
                            decoration:
                                BoxDecoration(color: MyColors.green, borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              children: [
                                MyWidget().getTextWidget(rs,
                                    text: '$trialLeftDate ${trialLeftDate! > 1 ? 'days' : 'day'} Left in Trial',
                                    color: Colors.white),
                                MyWidget().getTextWidget(rs,
                                    text: tr('explorePremium'),
                                    color: Colors.white,
                                    isBold: true,
                                    hasUnderline: true),
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
