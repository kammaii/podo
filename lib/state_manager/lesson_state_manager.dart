import 'package:get/get.dart';
import 'package:podo/items/lesson_card.dart';
import 'package:podo/items/user_info.dart';
import 'package:podo/screens/lesson/lesson_frame.dart';
import 'package:podo/values/my_strings.dart';


class LessonStateManager extends GetxController {
  late List<LessonCard> cards;
  late bool isPlayBtnActive;
  late int thisIndex;
  late double audioPercent;
  late int practiceCount;
  late String? practiceDirectionText;
  static const Map<int, String> practiceDirectionTexts = {
    0 : MyStrings.listen1,
    1 : MyStrings.repeat1,
    2 : MyStrings.listen2,
    3 : MyStrings.repeat2,
    4 : MyStrings.listen3,
    5 : MyStrings.repeat3,
  };


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
    practiceCount = 0;
    practiceDirectionText = '';
    update();
  }

  void setPracticeDirection(bool hasActionBtn) {
    audioPercent = 0;
    isPlayBtnActive = hasActionBtn;
    practiceDirectionText = practiceDirectionTexts[practiceCount];
    practiceCount++;
    if(practiceCount > 5) {
      print('연습 끝');
      practiceCount = 0;
    }
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