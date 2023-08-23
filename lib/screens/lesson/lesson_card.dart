
class LessonCard {
  late String id;
  late int orderId;
  late String type;
  late Map<String, dynamic> content;
  Map<String, dynamic>? detailTitle;
  Map<String, dynamic>? detailContent;

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String TYPE = 'type';
  static const String CONTENT = 'content';
  static const String DETAIL_TITLE = 'detailTitle';
  static const String DETAIL_CONTENT = 'detailContent';

  LessonCard.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    type = json[TYPE];
    content = json[CONTENT];
    detailTitle = json[DETAIL_TITLE] ?? null;
    detailContent = json[DETAIL_CONTENT] ?? null;
  }
}