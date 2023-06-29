import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo/common/database.dart';
import 'package:uuid/uuid.dart';

class FlashCard {
  late String id;
  late String front;
  late String back;
  String? audio;
  late DateTime date;
  bool isPlay = false;

  static const String ID = 'id';
  static const String FRONT = 'front';
  static const String BACK = 'back';
  static const String AUDIO = 'audio';
  static const String DATE = 'date';

  FlashCard() {
    id = const Uuid().v4();
  }

  FlashCard.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    front = json[FRONT];
    back = json[BACK];
    audio = json[AUDIO];
    Timestamp stamp = json[DATE];
    date = stamp.toDate();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map[ID] = id;
    map[FRONT] = front;
    map[BACK] = back;
    map[AUDIO] = audio ?? null;
    map[DATE] = Timestamp.now();
    return map;
  }


  void addFlashcard({required String front, required String back, String? audio}) {
    FlashCard flashCard = FlashCard();
    flashCard.front = front;
    flashCard.back = back;
    flashCard.audio = audio;
    Database().setFlashcard(flashCard: flashCard);
  }
}