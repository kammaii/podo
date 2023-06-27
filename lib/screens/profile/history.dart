import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class History {
  late String id;
  late String item;
  late String itemId;
  String? content;
  late DateTime date;

  History({required this.item, required this.itemId}) {
    id = const Uuid().v4();
    date = DateTime.now();
  }

  static const String ID = 'id';
  static const String ITEM = 'item';
  static const String ITEMID = 'itemId';
  static const String CONTENT = 'content';
  static const String DATE = 'date';

  History.fromJson(Map<String,dynamic> json) {
    id = json[ID];
    item = json[ITEM];
    itemId = json[ITEMID];
    if(json[CONTENT] != null) {
      content = json[CONTENT];
    }
    Timestamp stamp = json[DATE];
    date = stamp.toDate();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      ITEM: item,
      ITEMID: itemId,
      DATE: Timestamp.fromDate(date),
    };
    if(content != null) {
      map[CONTENT] = content;
    }
    return map;
  }
}
