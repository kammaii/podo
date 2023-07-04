import 'package:get/get.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/play_Stop_icon.dart';
import 'package:podo/screens/flashcard/flashcard.dart';

class FlashCardController extends GetxController {
  late bool isCheckedAll;
  late List<bool> isChecked;
  late bool isLongClicked;
  bool isShuffleChecked = false;
  List<FlashCard> cards = [];
  RxBool isViewAllClicked = false.obs;
  Map<String, PlayStopIcon> playStopIcons = {};



  init() {
    cards = LocalStorage().flashcards;
    isChecked = List.generate(cards.length, (index) => false);
    isCheckedAll = false;
    isLongClicked = false;
  }

  updateCard({required String id, required String front, required String back}) {
    for(FlashCard card in cards) {
      if(card.id == id) {
        card.front = front;
        card.back = back;
      }
    }
    update();
  }

  setCheckbox() {
    if(isCheckedAll) {
      isChecked = List.generate(cards.length, (index) => true);
    } else {
      isChecked = List.generate(cards.length, (index) => false);
    }
  }

  isCheckedAllClicked(bool value) {
    isCheckedAll = value;
    for(int i=0; i<isChecked.length; i++) {
      isChecked[i] = isCheckedAll;
    }
    update();
  }
}