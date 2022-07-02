import 'package:flutter_html/flutter_html.dart';

class Notice {
  final String noticeId;
  late final String tag;
  final String title;
  final Html content;
  final bool isOnBoard;
  final int actionType; // 0: no action, 1: textEdit + btn, 2: checkBox + btn
  final int? deadline;

  Notice({
    required this.noticeId,
    required this.title,
    required this.content,
    required this.isOnBoard,
    required this.actionType,
    this.deadline,
  }) {
    tag = noticeId.split('_')[0];
  }
}
