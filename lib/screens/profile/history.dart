import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class History {
  late String id;
  late String item;
  late String itemId;
  late DateTime date;

  History() {
    id = const Uuid().v4();
    date = DateTime.now();
  }

  static const String ID = 'id';
  static const String ITEM = 'item';
  static const String ITEMID = 'itemId';
  static const String DATE = 'date';

  History.fromJson(Map<String,dynamic> json) {
    id = json[ID];
    item = json[ITEM];
    itemId = json[ITEMID];
    Timestamp stamp = json[DATE];
    date = stamp.toDate();
  }

  Map<String, dynamic> toJson() => {
    ID: id,
    ITEM: item,
    ITEMID: itemId,
    DATE: Timestamp.fromDate(date),
  };
}
