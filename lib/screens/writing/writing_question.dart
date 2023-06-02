
class WritingQuestion {

  late String id;
  late int orderId;
  late int level;
  late Map<String,dynamic> title;

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String LEVEL = 'level';
  static const String TITLE = 'title';

  WritingQuestion.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    level = json[LEVEL];
    title = json[TITLE];
  }
}