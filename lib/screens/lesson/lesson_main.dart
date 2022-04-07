import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:podo/common_widgets/my_widget.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';


class LessonMain extends StatefulWidget {
  const LessonMain({Key? key, required this.course}) : super(key: key);
  final String course;

  @override
  _LessonMainState createState() => _LessonMainState();
}

class _LessonMainState extends State<LessonMain> {
  ScrollController scrollController = ScrollController();
  double sliverAppBarHeight = 200.0;
  double sliverAppBarMinimumHeight = 60.0;
  double sliverAppBarStretchOffset = 100.0;
  double itemHeight = 80.0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  Widget lessonList(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: itemHeight,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyWidget().getTextWidget('Lesson title', 20, MyColors.navy,),
              MyWidget().getTextWidget('Lesson sub title', 18, MyColors.grey,),
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
      if (sliverAppBarHeight - scrollController.offset >
          sliverAppBarMinimumHeight) {
        topMargin -= scrollController.offset;
        topMarginPlayBtn -= scrollController.offset;
      } else {
        topMargin = -100.0;
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
        flexibleSpace: Container(
          color: MyColors.navyLight,
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
              return lessonList(index);
            },
            childCount: 10,
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
                elevation: 10,
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
