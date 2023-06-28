import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/lesson_course_controller.dart';
import 'package:podo/screens/lesson/lesson.dart';
import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:podo/screens/lesson/lesson_summary_main.dart';
import 'package:podo/screens/message/cloud_message.dart';
import 'package:podo/screens/message/cloud_message_controller.dart';
import 'package:podo/screens/premium/premium_main.dart';
import 'package:podo/screens/profile/history.dart';
import 'package:podo/screens/profile/user.dart';
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
  String language = User().language;
  String sampleImage = 'assets/images/course_hangul.png';
  final KO = 'ko';
  final LESSON = 'Lesson';
  int lessonIndex = -1;
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
    bool isCompleted = false;
    if (lessonMap is Map) {
      lesson = Lesson.fromJson(lessonMap as Map<String, dynamic>);
      if (lesson.type == LESSON) {
        lessonIndex++;
        for (dynamic historyJson in User().lessonHistory) {
          History history = History.fromJson(historyJson);
          if (history.itemId == lesson.id) {
            isCompleted = true;
            break;
          }
        }
      }
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
                          Get.toNamed('/lessonSummaryMain', arguments: lesson);
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
                f: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PremiumMain()));
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
            color: MyColors.purpleLight,
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
    final cloudController = Get.put(CloudMessageController());
    for(dynamic snapshot in User().cloudMessageHistory) {
      History history = History.fromJson(snapshot);
      if (history.itemId == CloudMessage().id) {
        cloudController.setHasReplied(true);
        break;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Visibility(
              visible: CloudMessage().isInDate != null && CloudMessage().isInDate!,
              child: InkWell(
                onTap: () {
                  Get.toNamed('cloudMessageMain');
                },
                child: Container(
                  color: MyColors.greenLight,
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
                                  text: CloudMessage().title?[KO] ?? '',
                                  isKorean: true,
                                  size: 18,
                                  color: MyColors.purple,
                                  maxLine: 1),
                              const SizedBox(height: 5),
                              MyWidget().getTextWidget(
                                  text: CloudMessage().title?[User().language] ?? '',
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
                                  text: cloudController.hasReplied.value ? MyStrings.replied : MyStrings.replyPodo,
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
                  physics: const BouncingScrollPhysics(),
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
