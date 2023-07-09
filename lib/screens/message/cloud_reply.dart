import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:uuid/uuid.dart';

class CloudReply {
  late String id;
  late String userId;
  late String userName;
  late String reply;
  late DateTime date;
  late bool isSelected;

  CloudReply(String text) {
    id = const Uuid().v4();
    userId = User().id;
    userName = User().name;
    reply = text;
    date = DateTime.now();
    isSelected = false;
  }

  static const String ID = 'id';
  static const String USER_ID = 'userId';
  static const String USER_NAME = 'userName';
  static const String REPLY = 'reply';
  static const String DATE = 'date';
  static const String IS_SELECTED = 'isSelected';

  Map<String, dynamic> toJson() => {
    ID: id,
    USER_ID: userId,
    USER_NAME: userName,
    REPLY: reply,
    DATE: Timestamp.fromDate(date),
    IS_SELECTED: isSelected,
  };

  CloudReply.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    userId = json[USER_ID];
    userName = json[USER_NAME];
    reply = json[REPLY];
    Timestamp stamp = json[DATE];
    date = stamp.toDate();
    isSelected = json[IS_SELECTED];
  }
}
