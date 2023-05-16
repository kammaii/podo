import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podo/common/cloud_storage.dart';

class PlayAudio {
  static final PlayAudio _instance = PlayAudio.init();

  factory PlayAudio() {
    return _instance;
  }

  AudioPlayer player = AudioPlayer();

  PlayAudio.init() {
    debugPrint('playAudio 초기화');
  }

  void playFlashcard(String? audio) async {
    if(audio != null) {
      List<String> audioRegex = audio.split(RegExp(r'_+'));
      String url = await CloudStorage().getLessonAudio(folderRef: audioRegex[0], fileRef: audioRegex[1]);
      await player.setUrl(url);
      await player.play();
    }
  }

  void playReading(String? audio) async {
    if(audio != null) {
      List<String> audioRegex = audio.split(RegExp(r'_+'));
      String url = await CloudStorage().getReadingAudio(folderRef: audioRegex[0], fileRef: audioRegex[1]);
      await player.setUrl(url);
      await player.play();
    }
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
