import 'package:get/get.dart';
import 'package:podo/items/lesson_card.dart';
import 'package:podo/items/user_info.dart';
import 'package:podo/screens/lesson/lesson_frame.dart';


class LessonStateManager extends GetxController {
  late List<LessonCard> cards;
  late bool isPlayBtnActive;
  late int thisIndex;
  late double audioPercent;


  @override
  void onInit() {
    cards = SampleLesson().getSampleLessons(); //todo: DB에서 해당 레슨카드 가져오기
    for (LessonCard card in cards) {
      UserInfo().favorites!.contains(card.uniqueId)
          ? card.isFavorite = true
          : card.isFavorite = false;
    }
    cards[0].audio != null
        ? isPlayBtnActive = true
        : isPlayBtnActive = false;
    thisIndex = 0;
    audioPercent = 0.0;
    update();
  }

  void setPlayBtn(bool isActive) {
    isPlayBtnActive = isActive;
    update();
  }

  void setFavorite(int index, bool isFavorite) {
    cards[index].isFavorite = isFavorite;
    update();
  }

  void setThisIndex(int index) {
    thisIndex = index;
    update();
  }
}