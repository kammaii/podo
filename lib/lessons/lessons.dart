// import 'package:flutter/material.dart';
// import 'package:podo/lessons/lesson_item.dart';
// import 'package:podo/lessons/lesson_strings.dart';
// import 'package:podo/lessons/lesson_summary.dart';
//
// import 'lesson_title.dart';
//
// class Lessons {
//
//   static final Lessons _instance = Lessons.init();
//
//   factory Lessons() {
//     return _instance;
//   }
//
//   static const String TITLE = 'title';
//   static const String SUBTITLE = 'subTitle';
//   static const String LESSON = 'lesson';
//   static const String SUMMARY = 'summary';
//
//
//   Lessons.init() {
//     debugPrint('Lessons 초기화');
//   }
//   //
//   // Lesson getBasicLesson(int index) {
//   //   String title = basicLessonList[index][TITLE]!;
//   //   String subTitle = basicLessonList[index][SUBTITLE]!;
//   //   List<LessonItem> lessonItems = basicLessonItemList[index];
//   //   List<LessonSummary> lessonSummaries = basicLessonSummaries[index];
//   //   Lesson lesson = Lesson(index, title, subTitle, lessonItems, lessonSummaries);
//   //   return lesson;
//   // }
//
//   static Map<int, Map<String, List<dynamic>>> basicLesson = {
//     0 : {TITLE : ['title0'], SUBTITLE : ['subtitle0'],
//       LESSON : [
//         LessonItem().setExplainItem(LessonStrings.basic0_page0_0),
//         LessonItem().setAudioItem(LessonStrings.basic0_page1_0, LessonStrings.basic0_page1_1, LessonStrings.basic0_page1_2, 'audio'),
//         LessonItem().setExplainItem(LessonStrings.basic0_page2_0),
//         LessonItem().setExplainItem(LessonStrings.basic0_page3_0),
//       ],
//       SUMMARY : [
//         LessonSummary(0, LessonStrings.basic0_sum0_kr, LessonStrings.basic0_sum0_en, LessonStrings.basic0_sum0_explain, [LessonStrings.basic0_sum0_example_0,LessonStrings.basic0_sum0_example_1]),
//         LessonSummary(1, LessonStrings.basic0_sum0_kr, LessonStrings.basic0_sum0_en, LessonStrings.basic0_sum0_explain, [LessonStrings.basic0_sum0_example_0,LessonStrings.basic0_sum0_example_1]),
//       ]
//     },
//     1 : {TITLE : ['title1'], SUBTITLE : ['subtitle1'],
//       LESSON : [
//         LessonItem().setExplainItem(LessonStrings.basic0_page0_0),
//         LessonItem().setAudioItem(LessonStrings.basic0_page1_0, LessonStrings.basic0_page1_1, LessonStrings.basic0_page1_2, 'audio'),
//         LessonItem().setExplainItem(LessonStrings.basic0_page2_0),
//         LessonItem().setExplainItem(LessonStrings.basic0_page3_0),
//       ],
//       SUMMARY : [
//         LessonSummary(0, LessonStrings.basic0_sum0_kr, LessonStrings.basic0_sum0_en, LessonStrings.basic0_sum0_explain, [LessonStrings.basic0_sum0_example_0,LessonStrings.basic0_sum0_example_1]),
//         LessonSummary(1, LessonStrings.basic0_sum0_kr, LessonStrings.basic0_sum0_en, LessonStrings.basic0_sum0_explain, [LessonStrings.basic0_sum0_example_0,LessonStrings.basic0_sum0_example_1]),
//       ]
//     },
//     2 : {TITLE : ['title2'], SUBTITLE : ['subtitle2'],
//       LESSON : [
//         LessonItem().setExplainItem(LessonStrings.basic0_page0_0),
//         LessonItem().setAudioItem(LessonStrings.basic0_page1_0, LessonStrings.basic0_page1_1, LessonStrings.basic0_page1_2, 'audio'),
//         LessonItem().setExplainItem(LessonStrings.basic0_page2_0),
//         LessonItem().setExplainItem(LessonStrings.basic0_page3_0),
//       ],
//       SUMMARY : [
//         LessonSummary(0, LessonStrings.basic0_sum0_kr, LessonStrings.basic0_sum0_en, LessonStrings.basic0_sum0_explain, [LessonStrings.basic0_sum0_example_0,LessonStrings.basic0_sum0_example_1]),
//         LessonSummary(1, LessonStrings.basic0_sum0_kr, LessonStrings.basic0_sum0_en, LessonStrings.basic0_sum0_explain, [LessonStrings.basic0_sum0_example_0,LessonStrings.basic0_sum0_example_1]),
//       ]
//     },
//   };
// }