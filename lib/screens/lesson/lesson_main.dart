import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:podo/common_widgets/my_widget.dart';
import 'package:podo/lessons/lessons.dart';
import 'package:podo/screens/lesson/lesson_frame.dart';
import 'package:podo/screens/subscribe/subscribe.dart';
import 'package:podo/user/user_info.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';


class LessonMain extends StatefulWidget {
  const LessonMain({Key? key, required this.course, required this.courseImage}) : super(key: key);
  final String course;
  final String courseImage;

  @override
  _LessonMainState createState() => _LessonMainState();
}

class _LessonMainState extends State<LessonMain> {
  ScrollController scrollController = ScrollController();
  double sliverAppBarHeight = 200.0;
  double sliverAppBarStretchOffset = 100.0;
  double itemHeight = 80.0;
  late List<Widget> lessonWidgetList;


  @override
  void initState() {
    super.initState();
    scrollController.addListener(() => setState(() {}));
    lessonWidgetList = [];
    for(int i=0; i<Lessons.basicLesson.length; i++) {
      if(!UserInfo().isPremium) {
        if(i==0) {
          lessonWidgetList.add(lessonList(i, false));
        } else if(i==1) {
          lessonWidgetList.add(premiumCard());
        } else {
          lessonWidgetList.add(lessonList(i-1, true));
        }

      } else {
        lessonWidgetList.add(lessonList(i, false));
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  Widget lessonList(int index, bool isLocked) {
    String lessonTitle = Lessons.basicLesson[index]![Lessons.TITLE]![0].toString();
    String lessonSubTitle = Lessons.basicLesson[index]![Lessons.SUBTITLE]![0].toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: itemHeight,
      child: Card(
        color: isLocked ? MyColors.navyLightLight : Colors.white,
        child: InkWell(
          onTap: (){
            Get.to(const LessonFrame());
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyWidget().getTextWidget(lessonTitle, 20, isLocked ? MyColors.grey : MyColors.navy,),
                MyWidget().getTextWidget(lessonSubTitle, 18, MyColors.grey,),
              ],
            ),
          ),
        ),
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
              MyWidget().getTextWidget(MyStrings.unlockEveryLessons, 18, Colors.black),
              const SizedBox(height: 10),
              MyWidget().getRoundBtnWidget(false, MyStrings.startFreeTrial, MyColors.purple, Colors.white, (){
               Navigator.push(context, MaterialPageRoute(builder: (context) => const Subscribe()));
              },innerVerticalPadding: 8)
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
        title: MyWidget().getTextWidget(widget.course, 18, MyColors.purple, isBold: true),
        flexibleSpace: Stack(
          children: [
            Container(
              color: MyColors.navyLight,
            ),
            Positioned(
              child: Hero(
                tag: 'courseImage:${widget.course}',
                child: Image.asset(
                  widget.courseImage,
                  width: 250,
                ),
              ),
              top: -50,
              right: -30,
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 10.0),
                decoration: const BoxDecoration(
                  color: MyColors.navy,
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        MyWidget().getTextWidget(MyStrings.nextLesson, 15, Colors.white, isBold: true,),
                        MyWidget().getTextWidget('~아/어요', 20, Colors.white,),
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
