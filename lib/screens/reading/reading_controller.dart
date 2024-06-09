import 'package:get/get.dart';
import 'package:podo/screens/reading/reading_title.dart';

class ReadingController extends GetxController {
  RxList<bool>? isExpanded;
  RxMap<dynamic, dynamic> hasFlashcard = {}.obs;
  RxMap<dynamic, dynamic> isCompleted = {}.obs;
  RxBool hasFavoriteReading = false.obs;
  late List<ReadingTitle> readingTitles;


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