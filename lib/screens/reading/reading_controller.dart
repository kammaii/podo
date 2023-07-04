import 'package:get/get.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/values/my_strings.dart';

class ReadingController extends GetxController {
  RxList<bool>? isExpanded;
  RxList<bool> hasFlashcard = <bool>[].obs;

  initIsExpanded(int length) {
    isExpanded ??= List.generate(length, (index) => false).obs;
  }

  setIsExpanded(int index, bool value) {
    isExpanded![index] = value;
  }

  bool getIsExpanded(int index) {
    return isExpanded![index];
  }

}