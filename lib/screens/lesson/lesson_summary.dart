import 'package:uuid/uuid.dart';

class LessonSummary {
  late String id;
  late int orderId;
  late Map<String, dynamic> content;
  List<dynamic>? examples;

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String CONTENT = 'content';
  static const String EXAMPLES = 'examples';

  LessonSummary.fromJson(Map<String, dynamic> json)
      : id = json[ID],
        orderId = json[ORDERID],
        content = json[CONTENT],
        examples = json[EXAMPLES] ?? null;
}