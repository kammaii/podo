import 'package:get/get.dart';

class FlashCardController extends GetxController {
  late bool isCheckedAll;
  late List<bool> isChecked;
  late bool isLongClicked;
  bool isRandomChecked = false;


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