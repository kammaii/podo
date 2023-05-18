import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podo/common/cloud_storage.dart';

class PlayAudio {
  static final PlayAudio _instance = PlayAudio.init();

  factory PlayAudio() {
    return _instance;
  }

  late AudioPlayer player;

  PlayAudio.init() {
    player = AudioPlayer();
    debugPrint('playAudio 초기화');
  }

  void reset() {
    player.dispose();
    player = AudioPlayer();
  }

  void playFlashcard(String? audio) async {
    if(audio != null) {
      List<String> audioRegex = audio.split(RegExp(r'_+'));
      String url = await CloudStorage().getAudio(audio: audioRegex);
      await player.setUrl(url);
      await player.play();
    }
  }

  void playReading({required String readingId, required int index}) async {
    String url = await CloudStorage().getReadingAudio(folderRef: readingId, index: index);
    await player.setUrl(url);
    await player.play();
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
