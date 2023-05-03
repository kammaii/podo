import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class FlashCard {
  late String id;
  late String ko;
  late String fo;
  String? audio;
  late DateTime date;

  static const String ID = 'id';
  static const String KO = 'ko';
  static const String FO = 'fo';
  static const String AUDIO = 'audio';
  static const String DATE = 'date';

  FlashCard() {
    id = const Uuid().v4();
  }

  FlashCard.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    ko = json[KO];
    fo = json[FO];
    audio = json[AUDIO];
    Timestamp stamp = json[DATE];
    date = stamp.toDate();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map[ID] = id;
    map[KO] = ko;
    map[FO] = fo;
    map[AUDIO] = audio ?? null;
    map[DATE] = Timestamp.now();
    return map;
  }
}