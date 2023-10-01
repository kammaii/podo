import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
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
  bool isBasicUser = User().status == 1;
  bool isNewUser = User().status == 0;
  late ResponsiveSize rs;

  @override
  Widget build(BuildContext context) {
    rs = ResponsiveSize(context);
    Lesson lesson = Get.arguments;
    summaries = [];
    final Query query = FirebaseFirestore.instance
        .collection('Lessons/${lesson.id}/LessonSummaries')
        .orderBy('orderId', descending: false);

    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: rs.getSize(56),
            height: rs.getSize(56),
            child: FloatingActionButton(
              heroTag: 'learningBtn',
              onPressed: () {
                Get.toNamed(MyStrings.routeLessonFrame, arguments: lesson);
              },
              backgroundColor: MyColors.green,
              child: Icon(Icons.play_arrow_rounded, size: rs.getSize(40)),
            ),
          ),
          SizedBox(height: rs.getSize(5)),
          MyWidget().getTextWidget(
            rs,
            text: tr('learning'),
            color: MyColors.greenDark,
            isBold: true,
          ),
          SizedBox(height: rs.getSize(15)),
          isNewUser
              ? const SizedBox.shrink()
              : SizedBox(
                  width: rs.getSize(56),
                  height: rs.getSize(56),
                  child: FloatingActionButton(
                    heroTag: 'wiringBtn',
                    onPressed: () {
                      isBasicUser
                          ? Get.toNamed(MyStrings.routePremiumMain)
                          : Get.toNamed(MyStrings.routeWritingMain, arguments: lesson.id);
                    },
                    backgroundColor: isBasicUser ? MyColors.grey : MyColors.pinkDark,
                    child:
                        Icon(isBasicUser ? FontAwesomeIcons.lock : FontAwesomeIcons.penToSquare, size: rs.getSize(25)),
                  ),
                ),
          SizedBox(height: rs.getSize(5)),
          isNewUser
              ? const SizedBox.shrink()
              : MyWidget().getTextWidget(
                  rs,
                  text: tr('writing'),
                  color: isBasicUser ? MyColors.grey : MyColors.wine,
                  isBold: true,
                ),
          SizedBox(height: rs.getSize(10)),
        ],
      ),
      appBar: MyWidget().getAppbar(rs, title: tr('lessonSummary')),
      body: SafeArea(
        child: FutureBuilder(
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
                          Container(height: rs.getSize(10), width: rs.getSize(10), color: MyColors.purple),
                          SizedBox(width: rs.getSize(10)),
                          MyWidget().getTextWidget(
                            rs,
                            text: lesson.title[KO],
                            size: 18,
                            color: MyColors.purple,
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
                            return getSummary(index);
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
      ),
    );
  }

  Widget getSummary(int index) {
    LessonSummary summary = summaries[index];
    double bottomPadding;
    index == summaries.length - 1 ? bottomPadding = rs.getSize(200) : bottomPadding = rs.getSize(40);
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyWidget().getTextWidget(rs,
              text: '${(index + 1).toString()}. ${summary.content[KO]} ',
              color: MyColors.purple,
              isBold: true,
              isKorean: true),
          SizedBox(height: rs.getSize(15)),
          Container(
            padding: EdgeInsets.all(rs.getSize(10)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyWidget().getTextWidget(rs, text: summary.content[fo]),
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
                                const SizedBox(
                                  height: 10,
                                  child: VerticalDivider(
                                    color: MyColors.purple,
                                    thickness: 1,
                                    width: 18,
                                  ),
                                ),
                                MyWidget().getTextWidget(rs, text: summary.examples[index], isKorean: true),
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
