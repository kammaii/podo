import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podo/items/user_info.dart';
import 'package:podo/screens/lesson/lesson_card.dart';
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
  final List<String> directionTexts1 = [MyStrings.listen1, MyStrings.listen2, MyStrings.listen3];
  final List<String> directionTexts2 = [MyStrings.repeat1, MyStrings.repeat2, MyStrings.repeat3];
  final List<String> praiseComments = [MyStrings.praise1, MyStrings.praise2, MyStrings.praise3];
  late AudioPlayer player;
  late ScrollPhysics scrollPhysics;

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
    scrollPhysics = const AlwaysScrollableScrollPhysics();
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
    double audioSpeed = 1;


    switch (practiceCount) {
      case 0:
        audioSpeed = 0.6;
        break;

      case 1:
        audioSpeed = 0.8;
        break;

      case 2:
        audioSpeed = 1.0;
        break;

      case 3:
        direction = praiseComments[Random().nextInt(praiseComments.length)];
        setResponseBtn(btn2: true);
        update();
        break;
    }

    if(practiceCount < 3) {
      direction = directionTexts1[practiceCount];
      playAudio(audioSpeed);

      isResponseBtn1Active = false;
      isResponseBtn2Active = false;
      isAudioProgressActive = true;
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
    if(cards[thisIndex].type == MyStrings.repeat) {
      player = AudioPlayer();
      player.positionStream.listen((position) {
        currentPosition = position;
        if(duration!.inMilliseconds > 0) {
          audioProgress = currentPosition.inMilliseconds / duration!.inMilliseconds;
          audioProgress = num.parse(audioProgress.toStringAsFixed(3)).toDouble();
        } else {
          audioProgress = 0.0;
        }
        if (audioProgress > 1) {
          audioProgress = 1;
        }
        update();
      });

      player.playerStateStream.listen((event) {
        print('listener fired : ${event.processingState}');
        if (event.processingState == ProcessingState.completed) {
          print('끝!');
          direction = directionTexts2[practiceCount];
          audioProgress = 0;
          setResponseBtn(btn1: true);
          isAudioProgressActive = false;
          update();
        }
      });
    }
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
    //stopListener = true;
    thisIndex = index;
    LessonCard card = cards[thisIndex];
    initIndexChange();
    //update();
    //stopListener = false;

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

  void doUpdate() {
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
