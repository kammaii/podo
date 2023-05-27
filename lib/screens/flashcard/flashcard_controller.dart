import 'package:get/get.dart';
import 'package:podo/screens/flashcard/flashcard.dart';

class FlashCardController extends GetxController {
  late bool isCheckedAll;
  late List<bool> isChecked;
  late bool isLongClicked;
  bool isRandomChecked = false;
  List<FlashCard> cards = [];

  updateCard({required String id, required String front, required String back}) {
    for(FlashCard card in cards) {
      if(card.id == id) {
        card.front = front;
        card.back = back;
      }
    }
    update();
  }

  initChecks(int length) {
    isCheckedAll = false;
    isChecked = List.generate(length, (index) => false);
    isLongClicked = false;
  }

  isCheckedAllClicked(bool value) {
    isCheckedAll = value;
    for(int i=0; i<isChecked.length; i++) {
      isChecked[i] = isCheckedAll;
    }
    update();
  }
}