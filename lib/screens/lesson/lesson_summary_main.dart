import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:podo/common/ads_controller.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/lesson/lesson.dart';
import 'package:podo/screens/lesson/lesson_summary.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import '../my_page/user.dart';

class LessonSummaryMain extends StatelessWidget {
  LessonSummaryMain({Key? key}) : super(key: key);

  late List<LessonSummary> summaries;
  final KO = 'ko';
  String fo = User().language;
  late bool isOptionsActive;
  late ResponsiveSize rs;
  late BuildContext cont;
  static const LEARNING = 'learning';
  static const WRITING = 'writing';
  static const READING = 'reading';
  static const SPEAKING = 'speaking';

  Widget getFloatingBtn({required String btnName, required Function() fn}) {
    String tag = '${btnName}Btn';
    IconData iconData = Icons.play_arrow_rounded;
    double iconSize = 50;
    Color bgColor = MyColors.green;
    Color nameColor = MyColors.greenDark;

    switch (btnName) {
      case WRITING:
        iconData = FontAwesomeIcons.penToSquare;
        iconSize = 23;
        bgColor = MyColors.pink;
        nameColor = MyColors.wine;
        break;

      case SPEAKING:
        iconData = CupertinoIcons.text_bubble;
        iconSize = 25;
        bgColor = MyColors.mustardLight;
        nameColor = MyColors.mustard;
        break;

      case READING:
        iconData = CupertinoIcons.book;
        iconSize = 23;
        bgColor = MyColors.navyLight;
        nameColor = MyColors.purple;
        break;
    }

    if (btnName != LEARNING && !isOptionsActive) {
      iconData = FontAwesomeIcons.lock;
      fn = () {
        MyWidget().showDialog(cont, rs, content: tr('wantUnlockLesson'), yesFn: () {
          Get.toNamed(MyStrings.routePremiumMain);
        }, hasPremiumTag: true, hasNoBtn: false, yesText: tr('explorePremium'));
      };
    }

    return Column(
      children: [
        SizedBox(
          width: rs.getSize(btnName == LEARNING ? 60 : 45),
          height: rs.getSize(btnName == LEARNING ? 60 : 45),
          child: FloatingActionButton(
            shape: const CircleBorder(),
            heroTag: tag,
            onPressed: fn,
            backgroundColor: bgColor,
            child: Icon(iconData, size: rs.getSize(iconSize)),
          ),
        ),
        SizedBox(height: rs.getSize(5)),
        MyWidget().getTextWidget(
          rs,
          size: 13,
          text: tr(btnName),
          color: nameColor,
          isBold: true,
        ),
        SizedBox(height: rs.getSize(15)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    cont = context;
    rs = ResponsiveSize(context);
    bool isPremiumUser = User().status == 2 || User().status == 3;
    Lesson lesson = Get.arguments;
    bool isFreeOptions = lesson.isFreeOptions ?? false;
    isFreeOptions || isPremiumUser ? isOptionsActive = true : isOptionsActive = false;

    summaries = [];
    final Query query = FirebaseFirestore.instance
        .collection('Lessons/${lesson.id}/LessonSummaries')
        .orderBy('orderId', descending: false);

    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          lesson.isSpeakingReleased ? getFloatingBtn(btnName: SPEAKING, fn: () {}) : const SizedBox.shrink(),
          lesson.isReadingReleased
              ? getFloatingBtn(
                  btnName: READING,
                  fn: () async {
                    Get.toNamed(MyStrings.routeReadingFrame, arguments: lesson.readingId!);
                  })
              : const SizedBox.shrink(),
          getFloatingBtn(
              btnName: WRITING,
              fn: () {
                isOptionsActive
                    ? Get.toNamed(MyStrings.routeWritingMain, arguments: lesson.id)
                    : MyWidget().showDialog(context, rs, content: tr('wantUnlockLesson'), yesFn: () {
                        Get.toNamed(MyStrings.routePremiumMain);
                      }, hasPremiumTag: true, hasNoBtn: false, yesText: tr('explorePremium'));
              }),
          getFloatingBtn(
              btnName: LEARNING,
              fn: () {
                if (!isPremiumUser && !lesson.adFree) {
                  MyWidget().showDialog(context, rs, content: tr('watchRewardAdLesson'), yesFn: () {
                    Get.toNamed(MyStrings.routeLessonFrame, arguments: lesson);
                    AdsController().showRewardAd();
                  }, hasNoBtn: false, textBtnText: tr('explorePremium'), textBtnFn: (){Get.toNamed(MyStrings.routePremiumMain);});
                } else {
                  Get.toNamed(MyStrings.routeLessonFrame, arguments: lesson);
                }
              }),
        ],
      ),
      appBar: MyWidget().getAppbar(context, rs, title: tr('lessonSummary')),
      body: FutureBuilder(
          future: Database().getDocs(query: query),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
              for (dynamic snapshot in snapshot.data) {
                summaries.add(LessonSummary.fromJson(snapshot.data() as Map<String, dynamic>));
              }
              return Padding(
                padding: EdgeInsets.all(rs.getSize(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                            height: rs.getSize(10), width: rs.getSize(10), color: Theme.of(context).primaryColor),
                        SizedBox(width: rs.getSize(10)),
                        MyWidget().getTextWidget(
                          rs,
                          text: lesson.title[KO],
                          size: 18,
                          color: Theme.of(context).primaryColor,
                          isKorean: true,
                          isBold: true,
                        ),
                      ],
                    ),
                    SizedBox(height: rs.getSize(30)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: summaries.length,
                        itemBuilder: (BuildContext context, int index) {
                          return getSummary(context, index);
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Widget getSummary(BuildContext context, int index) {
    LessonSummary summary = summaries[index];
    double bottomPadding;
    index == summaries.length - 1 ? bottomPadding = rs.getSize(500) : bottomPadding = rs.getSize(40);
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyWidget().getTextWidget(rs,
              text: '${(index + 1).toString()}. ${summary.content[KO]} ',
              color: Theme.of(context).primaryColor,
              isBold: true,
              isKorean: true),
          SizedBox(height: rs.getSize(15)),
          Container(
            padding: EdgeInsets.all(rs.getSize(10)),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyWidget()
                    .getTextWidget(rs, text: summary.content[fo], color: Theme.of(context).secondaryHeaderColor),
                SizedBox(height: rs.getSize(15)),
                summary.examples.isNotEmpty
                    ? ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: summary.examples.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: rs.getSize(10)),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 10,
                                  child: VerticalDivider(
                                    color: Theme.of(context).primaryColor,
                                    thickness: 1,
                                    width: 18,
                                  ),
                                ),
                                Expanded(
                                  child: MyWidget().getTextWidget(rs,
                                      text: summary.examples[index],
                                      isKorean: true,
                                      color: Theme.of(context).secondaryHeaderColor),
                                ),
                              ],
                            ),
                          );
                        })
                    : const SizedBox.shrink()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
