import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/items/lesson_course.dart';
import 'package:podo/items/lesson_title.dart';
import 'package:podo/screens/lesson/lesson_frame.dart';
import 'package:podo/state_manager/lesson_state_manager.dart';
import 'package:podo/screens/subscribe/subscribe.dart';
import 'package:podo/items/user_info.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class LessonMain extends StatefulWidget {
  const LessonMain({Key? key}) : super(key: key);

  @override
  _LessonMainState createState() => _LessonMainState();
}

class _LessonMainState extends State<LessonMain> {
  ScrollController scrollController = ScrollController();
  double sliverAppBarHeight = 200.0;
  double sliverAppBarStretchOffset = 100.0;
  late List<Widget> lessonWidgetList;
  List<LessonTitle> sampleItems = [
    LessonTitle(level: 'beginner', orderId: 0, category: 'Future tense', title: '주말에 뭐 했어요?'),
    LessonTitle(level: 'beginner', orderId: 1, category: 'Future tense', title: '내일 뭐 할 거예요?', isVideo: true),
    LessonTitle(level: 'beginner', orderId: 2, category: 'Past tense', title: '밥을 먹었어요'),
    LessonTitle(level: 'beginner', orderId: 0, category: 'Future tense', title: '주말에 뭐 했어요?'),
    LessonTitle(level: 'beginner', orderId: 1, category: 'Future tense', title: '내일 뭐 할 거예요?', isVideo: true),
    LessonTitle(level: 'beginner', orderId: 2, category: 'Past tense', title: '밥을 먹었어요'),

  ];
  LessonCourse course = Get.arguments;
  String setLanguage = 'en'; //todo: 기기 설정에 따라 바뀌게 하기
  String sampleImage = 'assets/images/course_hangul.png';

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() => setState(() {}));
    lessonWidgetList = [];
    bool isPremium = UserInfo().isPremium;
    bool hasCategory = true;

    for (int i = 0; i < sampleItems.length; i++) {
      if (i != 0 && sampleItems[i].category == sampleItems[i - 1].category) {
        hasCategory = false;
      } else {
        hasCategory = true;
      }
      if (!isPremium) {
        bool isLocked;
        i == 0 ? isLocked = false : isLocked = true;
        lessonWidgetList.add(lessonList(sampleItems[i], hasCategory, isLocked));
      } else {
        lessonWidgetList.add(lessonList(sampleItems[i], hasCategory, false));
      }
    }

    if (!isPremium) {
      lessonWidgetList.insert(1, premiumCard());
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  Widget lessonList(LessonTitle title, bool hasCategory, bool isLocked) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          if (hasCategory)
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 5),
              child: MyWidget().getTextWidget(
                text: title.category,
                size: 25,
                color: MyColors.navyLight,
              ),
            ),
          Card(
            color: isLocked ? MyColors.navyLightLight : Colors.white,
            child: InkWell(
              onTap: () {
                final LessonStateManager controller = Get.put(LessonStateManager());
                controller.onInit();
                Get.to(LessonFrame());
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        MyWidget().getTextWidget(
                          text: 'lesson ${title.lessonId.split('_')[1]}',
                          size: 15,
                          color: MyColors.grey,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        if (title.isVideo != null)
                          title.isVideo!
                              ? const Icon(
                                  FontAwesomeIcons.youtube,
                                  color: MyColors.red,
                                )
                              : const SizedBox.shrink(),
                        const Spacer(),
                        //title.isCompleted ? const Icon(Icons.check_circle, color: MyColors.green,) : const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MyWidget().getTextWidget(
                      text: title.title,
                      size: 20,
                      color: isLocked ? MyColors.grey : MyColors.navy,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget premiumCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(FontAwesomeIcons.crown, color: MyColors.purple),
              const SizedBox(height: 10),
              MyWidget().getTextWidget(
                text: MyStrings.unlockEveryLessons,
                size: 18,
                color: Colors.black,
              ),
              const SizedBox(height: 10),
              MyWidget().getRoundBtnWidget(
                isRequest: false,
                text: MyStrings.startFreeTrial,
                bgColor: MyColors.purple,
                fontColor: Colors.white,
                f: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Subscribe()));
                },
                innerVerticalPadding: 8,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double topMargin = sliverAppBarHeight - 30.0;
    double topMarginPlayBtn = sliverAppBarHeight - 25.0;

    if (scrollController.hasClients) {
      topMargin -= scrollController.offset;
      if (sliverAppBarHeight - scrollController.offset >= 30) {
        topMarginPlayBtn -= scrollController.offset;
      } else {
        topMarginPlayBtn = 5.0;
      }
    }

    sliverAppBar() {
      return SliverAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: MyColors.purple,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        expandedHeight: sliverAppBarHeight,
        pinned: true,
        stretch: true,
        title: MyWidget().getTextWidget(
          text: course.title[setLanguage],
          size: 18,
          color: MyColors.purple,
          isBold: true,
        ),
        flexibleSpace: Stack(
          children: [
            Container(
              color: MyColors.navyLight,
            ),
            Positioned(
              top: -50,
              right: -30,
              child: Hero(
                tag: 'courseImage:${course.orderId}',
                child: Image.asset(
                  sampleImage,
                  width: 250,
                ),
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
        padding: const EdgeInsets.only(top: 60.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return lessonWidgetList[index];
            },
            childCount: lessonWidgetList.length,
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              controller: scrollController,
              slivers: [
                sliverAppBar(),
                sliverList(),
              ],
            ),
            Positioned(
              width: MediaQuery.of(context).size.width,
              top: topMargin,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30.0),
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                decoration: const BoxDecoration(
                  color: MyColors.navy,
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        MyWidget().getTextWidget(
                          text: MyStrings.nextLesson,
                          size: 15,
                          color: Colors.white,
                          isBold: true,
                        ),
                        MyWidget().getTextWidget(
                          text: '~아/어요',
                          size: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: topMarginPlayBtn,
              right: 60.0,
              child: FloatingActionButton(
                elevation: 0,
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: MyColors.navy,
                  size: 50.0,
                ),
                onPressed: () {},
              ),
            )
          ],
        ),
      ),
    );
  }
}
