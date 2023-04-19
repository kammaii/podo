import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/lesson/lesson.dart';
import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:podo/screens/lesson/lesson_frame.dart';
import 'package:podo/state_manager/lesson_state_manager.dart';
import 'package:podo/screens/subscribe/subscribe.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class LessonMain extends StatefulWidget {
  const LessonMain({Key? key}) : super(key: key);

  @override
  _LessonMainState createState() => _LessonMainState();
}

class _LessonMainState extends State<LessonMain> with TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  double sliverAppBarHeight = 200.0;
  double sliverAppBarStretchOffset = 100.0;
  LessonCourse course = Get.arguments;
  String language = 'en'; //todo: 기기 설정에 따라 바뀌게 하기
  String sampleImage = 'assets/images/course_hangul.png';
  String nextLesson = '~아/어요'; //todo: userInfo 에서  completeLessons 참고하기
  final KO = 'ko';
  final LESSON = 'Lesson';
  int lessonIndex = -1;
  bool isCompleted = true; //todo: userInfo 에서 가져오기
  double cardBorderRadius = 8;
  bool isImageVisible = true;
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
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
    if (lessonMap is Map) {
      lesson = Lesson.fromJson(lessonMap as Map<String, dynamic>);
      lesson.category == LESSON ? lessonIndex++ : null;
    }
    return Column(
      children: [
        lessonMap is String
            ? Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 5),
                child: MyWidget().getTextWidget(
                  text: lessonMap,
                  size: 25,
                  color: MyColors.navyLight,
                ),
              )
            : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(cardBorderRadius),
                      ),
                      color: lesson.isFree ? Colors.white : MyColors.navyLightLight,
                      child: InkWell(
                        onTap: () {
                          final LessonStateManager controller = Get.find<LessonStateManager>();
                          controller.onInit();
                          Get.to(LessonFrame());
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  MyWidget().getTextWidget(
                                    text:
                                        lesson.category == LESSON ? '$LESSON $lessonIndex' : lesson.category,
                                    size: 15,
                                    color: MyColors.grey,
                                  ),
                                  const SizedBox(width: 10),
                                  isCompleted
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: MyColors.green,
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                              const SizedBox(height: 10),
                              MyWidget().getTextWidget(
                                text: lesson.title[KO],
                                size: 20,
                                color: lesson.isFree ? MyColors.navy : MyColors.grey,
                              ),
                              const SizedBox(height: 10),
                              MyWidget().getTextWidget(
                                text: lesson.title[language],
                                size: 15,
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
                          top: 5,
                          right: 15,
                          child: Container(
                              decoration: BoxDecoration(
                                color: MyColors.pink,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(cardBorderRadius),
                                  bottomLeft: Radius.circular(cardBorderRadius),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              child: const Text('New', style: TextStyle(color: MyColors.red))))
                      : const SizedBox.shrink(),
                ],
              ),
      ],
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
      collapsedHeight: 60,
      pinned: true,
      stretch: true,
      title: MyWidget().getTextWidget(
        text: '${course.title[language]} (${course.lessons.length} ${MyStrings.lessons})',
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
              tag: 'courseImage:${course.id}',
            child: FadeTransition(
              opacity: animation,
              child: Image.asset(
                sampleImage,
                width: 250,
              ),
            ),
            ),
          ),
          const LinearProgressIndicator(
            value: 0.5,
            color: MyColors.purple,
            backgroundColor: MyColors.purpleLight,
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
            return lessonListWidget(course.lessons[index]);
          },
          childCount: course.lessons.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    lessonIndex = -1;
    double topMargin = sliverAppBarHeight - 30.0;
    double topMarginPlayBtn = sliverAppBarHeight - 25.0;

    if (scrollController.hasClients) {
      topMargin -= scrollController.offset;
      if (sliverAppBarHeight - scrollController.offset >= 34) {
        topMarginPlayBtn -= scrollController.offset;
      } else {
        topMarginPlayBtn = 9.0;
      }
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
                          text: nextLesson,
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
                onPressed: () {
                  //todo: nextLesson start
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
