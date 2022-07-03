import 'package:flutter_html/flutter_html.dart';

class Notice {
  final String noticeId;
  late final String tag; // #info, #quiz, #liveLesson
  final String title;
  final Html contents;
  final bool isOnBoard;

  // for #quiz, #liveLesson
  final int? deadline;

  // for #quiz
  final List<String>? examples;
  final String? answer;

  Notice({
    required this.noticeId,
    required this.title,
    required this.contents,
    required this.isOnBoard,
    this.deadline,
    this.examples,
    this.answer,
  }) {
    tag = noticeId.split('_')[0];
  }
}
