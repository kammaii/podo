import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/lesson_course_controller.dart';
import 'package:podo/screens/lesson/lesson.dart';
import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:podo/screens/lesson/lesson_summary_main.dart';
import 'package:podo/screens/subscribe/subscribe.dart';
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
  double sliverAppBarHeight = 200.0;
  double sliverAppBarStretchOffset = 100.0;
  late LessonCourse course;
  String language = 'en'; //todo: 기기 설정에 따라 바뀌게 하기
  String sampleImage = 'assets/images/course_hangul.png';
  String nextLesson = '~아/어요'; //todo: userInfo 에서  completeLessons 참고하기
  final KO = 'ko';
  final LESSON = 'Lesson';
  int lessonIndex = -1;
  bool isCompleted = true; //todo: userInfo 에서 가져오기
  final cardBorderRadius = 8.0;
  late AnimationController animationController;
  late Animation<double> animation;
  LessonCourseController controller = Get.find<LessonCourseController>();

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
      lesson.type == LESSON ? lessonIndex++ : null;
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
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          Get.to(LessonSummaryMain(), arguments: lesson);
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
                                        lesson.type == LESSON ? '$LESSON $lessonIndex' : lesson.type,
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
                text: MyStrings.startFreeTrial,
                bgColor: MyColors.purple,
                fontColor: Colors.white,
                f: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Subscribe()));
                },
                verticalPadding: 8,
              )
            ],
          ),
        ),
      ),
    );
  }

  sliverAppBar() {
    int lessonCount = 0;
    for(dynamic lesson in course.lessons) {
      if(lesson is Map) {
        lessonCount++;
      }
    }
    return SliverAppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        color: MyColors.purple,
        onPressed: () {
          controller.setVisibility(true);
        },
      ),
      expandedHeight: sliverAppBarHeight,
      collapsedHeight: 60,
      pinned: true,
      stretch: true,
      title: MyWidget().getTextWidget(
        text: '${course.title[language]} ($lessonCount ${MyStrings.lessons})',
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
            child: FadeTransition(
              opacity: animation,
              child: Image.asset(
                sampleImage,
                width: 250,
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
    lessonIndex = -1;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          controller: scrollController,
          slivers: [
            sliverAppBar(),
            sliverList(),
          ],
        ),
      ),
    );
  }
}
