import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podo/state_manager/lesson_state_manager.dart';

class PlayAudio {

  static final PlayAudio _instance = PlayAudio.init();

  factory PlayAudio() {
    return _instance;
  }

  late Duration? duration;
  late Duration currentPosition;

  AudioPlayer player = AudioPlayer();

  PlayAudio.init() {
    debugPrint('playAudio 초기화');
  }

  void setAudios(String lessonId) {
    //todo: 해당 레슨의 모든 오디오를 미리 불러와서 저장하기
  }

  void playAudio(String audio) async {
    final controller = Get.find<LessonStateManager>();
    duration = const Duration(seconds: 0);
    currentPosition = const Duration(seconds: 0);
    duration = await player.setAsset('assets/audio/$audio');
    player.playerStateStream.listen((event) {
      if(event.processingState == ProcessingState.completed) {
        print('끝!');
        controller.audioPercent = 0;
        controller.update();
      }
    });
    player.positionStream.listen((position) {
      currentPosition = position;
      double percentTemp = currentPosition.inMilliseconds / duration!.inMilliseconds;
      percentTemp = num.parse(percentTemp.toStringAsFixed(3)).toDouble();
      if(percentTemp > 1) {
        percentTemp = 1;
      }
      controller.audioPercent = percentTemp;
      controller.update();
    });
    await player.setVolume(1);
    await player.setSpeed(1);
    player.play();
  }


  void playCorrect() async {
    await player.setAsset('assets/audio/correct.mp3');
    await player.setVolume(0.1);
    player.play();
  }

  void playWrong() async {
    await player.setAsset('assets/audio/wrong.mp3');
    await player.setVolume(0.1);
    player.play();
  }

  void playYay() async {
    await player.setAsset('assets/audio/yay.mp3');
    await player.setVolume(0.1);
    player.play();
  }

}