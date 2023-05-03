import 'package:get/get.dart';

class FlashCardController extends GetxController {
  late bool isCheckedAll;
  late List<bool> isChecked;
  late bool isLongClicked;


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