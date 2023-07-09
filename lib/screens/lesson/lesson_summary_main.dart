import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    Lesson lesson = Get.arguments;
    summaries = [];
    final Query query = FirebaseFirestore.instance
        .collection('Lessons/${lesson.id}/LessonSummaries')
        .orderBy('orderId', descending: false);

    return FutureBuilder(
        future: Database().getDocs(query: query),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
            for (dynamic snapshot in snapshot.data) {
              summaries.add(LessonSummary.fromJson(snapshot.data() as Map<String, dynamic>));
            }
            return Scaffold(
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  isNewUser
                      ? const SizedBox.shrink()
                      : FloatingActionButton(
                          heroTag: 'wiringBtn',
                          onPressed: () {
                            isBasicUser
                                ? Get.toNamed(MyStrings.routePremiumMain)
                                : Get.toNamed(MyStrings.routeWritingMain, arguments: lesson.id);
                          },
                          backgroundColor: isBasicUser ? MyColors.grey : MyColors.green,
                          child:
                              Icon(isBasicUser ? FontAwesomeIcons.lock : FontAwesomeIcons.penToSquare, size: 25),
                        ),
                  const SizedBox(height: 5),
                  isNewUser
                      ? const SizedBox.shrink()
                      : MyWidget().getTextWidget(
                          text: MyStrings.writing,
                          size: 15,
                          color: isBasicUser ? MyColors.grey : MyColors.greenDark,
                          isBold: true,
                        ),
                  const SizedBox(height: 15),
                  FloatingActionButton(
                    heroTag: 'learningBtn',
                    onPressed: () {
                      Get.toNamed(MyStrings.routeLessonFrame, arguments: lesson);
                    },
                    backgroundColor: MyColors.pink,
                    child: const Icon(Icons.play_arrow_rounded, size: 40),
                  ),
                  const SizedBox(height: 5),
                  MyWidget().getTextWidget(
                    text: MyStrings.learning,
                    size: 15,
                    color: MyColors.wine,
                    isBold: true,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              appBar: MyWidget().getAppbar(title: MyStrings.lessonSummary),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(height: 10, width: 10, color: MyColors.purple),
                          const SizedBox(width: 10),
                          MyWidget().getTextWidget(
                            text: lesson.title[KO],
                            size: 18,
                            color: MyColors.purple,
                            isKorean: true,
                            isBold: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
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
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget getSummary(int index) {
    LessonSummary summary = summaries[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyWidget().getTextWidget(
            text: '${(index + 1).toString()}. ${summary.content[KO]} ',
            color: MyColors.purple,
            isBold: true,
            isKorean: true,
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyWidget().getTextWidget(text: summary.content[fo]),
                const SizedBox(height: 15),
                summary.examples != null
                    ? ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: summary.examples!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
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
                                MyWidget().getTextWidget(
                                  text: summary.examples![index],
                                  isKorean: true,
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
