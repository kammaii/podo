import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/screens/flashcard/flashcard_controller.dart';
import 'package:podo/screens/profile/user.dart';
import 'package:uuid/uuid.dart';

class FlashCard {
  late String id;
  late String itemId;
  late String front;
  late String back;
  String? audio;
  late DateTime date;
  bool isPlay = false;
  String? dateReview;

  static const String ID = 'id';
  static const String ITEM_ID = 'itemId';
  static const String FRONT = 'front';
  static const String BACK = 'back';
  static const String AUDIO = 'audio';
  static const String DATE = 'date';
  static const String DATE_REVIEW = 'dateReview';

  FlashCard() {
    id = const Uuid().v4();
    DateTime now = DateTime.now();
    date = now.subtract(Duration(milliseconds: now.millisecond, microseconds: now.microsecond));
  }

  FlashCard.fromJson(Map<String, dynamic> json, {bool isLocal = false}) {
    id = json[ID];
    itemId = json[ITEM_ID];
    front = json[FRONT];
    back = json[BACK];
    audio = json[AUDIO];
    if(!isLocal) {
      Timestamp stamp = json[DATE];
      date = stamp.toDate();
    } else {
      date = DateTime.parse(json[DATE]);
      dateReview = json[DATE_REVIEW];
    }
  }


  Map<String, dynamic> toJson({bool isLocal = false}) {
    Map<String, dynamic> map = {};
    map[ID] = id;
    map[ITEM_ID] = itemId;
    map[FRONT] = front;
    map[BACK] = back;
    map[AUDIO] = audio ?? null;
    if(!isLocal) {
      map[DATE] = Timestamp.fromDate(date);
    } else {
      map[DATE] = date.toIso8601String();
      map[DATE_REVIEW] = dateReview ?? null;
    }
    return map;
  }

  final controller = Get.put(FlashCardController());

  void addFlashcard({required String itemId, required String front, String? back, String? audio}) async {
    FlashCard flashcard = FlashCard();
    flashcard.itemId = itemId;
    flashcard.front = front;
    flashcard.back = back ?? '';
    flashcard.audio = audio;
    await Database().setDoc(collection: 'Users/${User().id}/FlashCards', doc: flashcard);
    LocalStorage().flashcards.insert(0, flashcard);
    setAndUpdate();
    print('플래시카드 추가');
  }

  void updateFlashcard({required FlashCard card}) async {
    DateTime now = DateTime.now();
    now = now.subtract(Duration(milliseconds: now.millisecond, microseconds: now.microsecond));
    card.date = now;
    await Database().updateFlashcard(card: card);
    for(FlashCard flashcard in LocalStorage().flashcards) {
      if(flashcard.id == card.id) {
        flashcard = card;
        break;
      }
    }
    setAndUpdate();
    print('플래시카드 수정');
  }

  void removeFlashcard({required String itemId}) async {
    List<FlashCard> cards = LocalStorage().flashcards;
    FlashCard cardToRemove = cards.firstWhere((card) => card.itemId == itemId);
    await Database().deleteDoc(collection: 'Users/${User().id}/FlashCards', docId: cardToRemove.id);
    cards.removeWhere((flashcard) => flashcard.itemId == itemId);
    setAndUpdate();
    print('플레시카드 삭제');
  }

  void removeFlashcards({required List<String> ids}) async {
    List<FlashCard> cards = LocalStorage().flashcards;
    if (ids.isNotEmpty) {
      final ref = 'Users/${User().id}/FlashCards';
      if (ids.length > 1) {
        await Database().deleteDocs(collection: ref, ids: ids);
        cards.removeWhere((card) => ids.contains(card.id));
      } else {
        await Database().deleteDoc(collection: ref, docId: ids[0]);
        cards.removeWhere((card) => card.id == ids[0]);
      }
      setAndUpdate();
      Get.back();
      print('플레시카드(들) 삭제');
    }
  }

  void setAndUpdate() {
    LocalStorage().setFlashcards();
    controller.init();
    controller.update();
  }
}