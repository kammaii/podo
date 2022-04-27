import 'package:podo/lessons/lesson_summary.dart';

import 'lesson_item.dart';

class Lesson {
  Lesson(this.id, this.title, this.subTitle, this.lessonItems, this.lessonSummaries);

  final int id;
  final String title;
  final String subTitle;
  final List<LessonItem> lessonItems;
  final List<LessonSummary> lessonSummaries;
}