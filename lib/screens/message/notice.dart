import 'package:flutter_html/flutter_html.dart';

class Notice {
  final String noticeId;
  late final String tag;
  final String title;
  final Html contents;
  final bool isOnBoard;
  final int actionType; // 0: no action, 1: correction req, 2: check answer, 3: booking
  final int? deadline;

  Notice(
    this.noticeId,
    this.title,
    this.contents,
    this.isOnBoard,
    this.actionType, {
    this.deadline,
  }) {
    tag = noticeId.split('_')[0];
  }
}
