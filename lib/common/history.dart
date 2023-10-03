import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:uuid/uuid.dart';

class History {
  late String id;
  late String item;
  late String itemId;
  String? content;
  late DateTime date;

  History() {
    id = const Uuid().v4();
    DateTime now = DateTime.now();
    date = now.subtract(Duration(milliseconds: now.millisecond, microseconds: now.microsecond));
  }

  static const String ID = 'id';
  static const String ITEM = 'item';
  static const String ITEMID = 'itemId';
  static const String CONTENT = 'content';
  static const String DATE = 'date';

  History.fromJson(Map<String,dynamic> json, {bool isLocal = false}) {
    id = json[ID];
    item = json[ITEM];
    itemId = json[ITEMID];
    if(json[CONTENT] != null) {
      content = json[CONTENT];
    }
    if(!isLocal) {
      Timestamp stamp = json[DATE];
      date = stamp.toDate();
    } else {
      date = DateTime.parse(json[DATE]);
    }
  }

  Map<String, dynamic> toJson({bool isLocal = false}) {
    Map<String, dynamic> map = {
      ID: id,
      ITEM: item,
      ITEMID: itemId,
    };
    if(content != null) {
      map[CONTENT] = content;
    }
    if(!isLocal) {
      map[DATE] = Timestamp.fromDate(date);
    } else {
      map[DATE] = date.toIso8601String();
    }
    return map;
  }

  Future<void> addHistory({required String item, required String itemId, String? content}) async {
    if(!LocalStorage().hasHistory(itemId: itemId)) {
      History history = History();
      history.item = item;
      history.itemId = itemId;
      history.content = content;
      print('HISTORY: ${history.toJson()}');
      await Database().setDoc(collection: 'Users/${User().id}/Histories', doc: history);
      LocalStorage().histories.insert(0, history);
      LocalStorage().setHistories();
      print('히스토리 추가');
    } else {
      print('히스토리 있음');
    }
  }
}
