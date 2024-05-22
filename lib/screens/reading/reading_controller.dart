import 'package:get/get.dart';

class ReadingController extends GetxController {
  RxList<bool>? isExpanded;
  RxMap<dynamic, dynamic> hasFlashcard = {}.obs;
  RxMap<dynamic, dynamic> isCompleted = {}.obs;
  RxBool hasFavoriteLesson = false.obs;

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