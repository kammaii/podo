import 'package:cloud_firestore/cloud_firestore.dart';

class KoreanBite {

  late String id;
  late int orderId;
  late Map<String, dynamic> title;
  late List<dynamic> tags;
  late DateTime date;
  late Map<String, dynamic> explain;
  bool isReleased = false;

  static const String ID = 'id';
  static const String ORDER_ID = 'orderId';
  static const String TITLE = 'title';
  static const String TAGS = 'tags';
  static const String DATE = 'date';
  static const String EXPLAIN = 'explain';
  static const String IS_RELEASED = 'isReleased';

  KoreanBite.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDER_ID];
    title = json[TITLE];
    if(json[TAGS] != null) {
      tags = json[TAGS];
    }
    Timestamp stamp = json[DATE];
    date = stamp.toDate();
    explain = json[EXPLAIN];
    isReleased = json[IS_RELEASED];
  }
}