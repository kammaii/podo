import 'dart:math';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podo/common_widgets/play_audio.dart';
import 'package:podo/items/lesson_card.dart';
import 'package:podo/items/user_info.dart';
import 'package:podo/screens/lesson/lesson_frame.dart';
import 'package:podo/values/my_strings.dart';

class LessonStateManager extends GetxController {
  late List<LessonCard> cards;
  late int thisIndex;
  late double audioProgress;
  late String direction;
  late bool isResponseBtn1Active;
  late bool isResponseBtn2Active;
  late bool isAudioProgressActive;
  late int practiceCount;
  late Duration? duration;
  late Duration currentPosition;
  final List<String> praiseComments = [MyStrings.praise1, MyStrings.praise2, MyStrings.praise3];
  late AudioPlayer player;

  @override
  void onInit() {
    super.onInit();
    cards = SampleLesson().getSampleLessons(); //todo: DB에서 해당 레슨카드 가져오기
    for (LessonCard card in cards) {
      UserInfo().favorites!.contains(card.uniqueId) ? card.isFavorite = true : card.isFavorite = false;
    }
    thisIndex = 0;
    audioProgress = 0.0;
    direction = MyStrings.swipe;
    isResponseBtn1Active = false;
    isResponseBtn2Active = false;
    isAudioProgressActive = false;
    practiceCount = 0;
    duration = const Duration(seconds: 0);
    currentPosition = const Duration(seconds: 0);
    player = AudioPlayer();
  }

  void playSpeak() {
    switch (practiceCount) {
      case 0 :
        direction = MyStrings.speakInKorean;
        setResponseBtn(btn1: true);
        isAudioProgressActive = false;
        break;

      case 1 :
        playAudio(1.0);
        player.playerStateStream.listen((event) {
          if (event.processingState == ProcessingState.completed) {
            print('끝!');
            direction = praiseComments[Random().nextInt(praiseComments.length)];
            setResponseBtn(btn2: true);
            update();
          }
        });
        break;
    }
    update();
  }

  void playRepeat() async {
    String directionText1 = '';
    String directionText2 = '';
    double audioSpeed = 1;

    switch (practiceCount) {
      case 0:
        directionText1 = MyStrings.listen1;
        directionText2 = MyStrings.repeat1;
        audioSpeed = 0.6;
        break;

      case 1:
        directionText1 = MyStrings.listen2;
        directionText2 = MyStrings.repeat2;
        audioSpeed = 0.8;
        break;

      case 2:
        directionText1 = MyStrings.listen3;
        directionText2 = MyStrings.repeat3;
        audioSpeed = 1.0;
        break;

      case 3:
        direction = praiseComments[Random().nextInt(praiseComments.length)];
        setResponseBtn(btn2: true);
        update();
        break;
    }

    if(practiceCount < 3) {
      direction = directionText1;

      isResponseBtn1Active = false;
      isResponseBtn2Active = false;
      isAudioProgressActive = true;

      player.positionStream.listen((position) {
        currentPosition = position;
        audioProgress = currentPosition.inMilliseconds / duration!.inMilliseconds;
        audioProgress = num.parse(audioProgress.toStringAsFixed(3)).toDouble();
        if (audioProgress > 1) {
          audioProgress = 1;
        }
        update();
      });

      duration = const Duration(seconds: 0);
      currentPosition = const Duration(seconds: 0);
      playAudio(audioSpeed);

      player.playerStateStream.listen((event) {
        print('listener fired');
        if (event.processingState == ProcessingState.completed) {
          print('끝!');
          direction = directionText2;
          audioProgress = 0;
          setResponseBtn(btn1: true);
          isAudioProgressActive = false;
          update();
        }
      });
    }
  }

  void setResponseBtn({bool btn1 = false, bool btn2 = false}) {
    if(btn1) {
      isResponseBtn1Active = true;
      isResponseBtn2Active = false;
    }
    if(btn2) {
      isResponseBtn1Active = false;
      isResponseBtn2Active = true;
    }
  }

  void playAudio(double speed) async {
    duration = await player.setAsset('assets/audio/${cards[thisIndex].audio}');
    await player.setVolume(1);
    await player.setSpeed(speed);
    player.play();
  }

  void initIndexChange() {
    player.dispose();
    player = AudioPlayer();
    audioProgress = 0.0;
    direction = MyStrings.swipe;
    isResponseBtn1Active = false;
    isResponseBtn2Active = false;
    isAudioProgressActive = false;
    practiceCount = 0;
    duration = const Duration(seconds: 0);
    currentPosition = const Duration(seconds: 0);
  }

  void changeIndex(int index) {
    thisIndex = index;
    LessonCard card = cards[thisIndex];
    initIndexChange();

    switch (card.type) {
      case MyStrings.subject:
        direction = MyStrings.swipe;
        update();
        break;

      case MyStrings.explain:
        direction = MyStrings.swipe;
        update();
        break;

      case MyStrings.repeat:
        direction = MyStrings.listen1;
        playRepeat();
        break;

      case MyStrings.speak:
        direction = MyStrings.speakInKorean;
        playSpeak();
        break;

      case MyStrings.quiz:
        direction = '';
        update();
        break;
    }
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
