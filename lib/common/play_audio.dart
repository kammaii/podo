import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podo/common/cloud_storage.dart';

class PlayAudio {
  static final PlayAudio _instance = PlayAudio.init();

  factory PlayAudio() {
    return _instance;
  }

  late AudioPlayer player;
  late StreamSubscription<PlayerState> stream;

  PlayAudio.init() {
    player = AudioPlayer();
    stream = player.playerStateStream.listen((event) {});
    debugPrint('playAudio 초기화');
  }

  void stop() {
    player.stop();
    stream.cancel();
  }

  void reset() {
    player.dispose();
    player = AudioPlayer();
  }

  void playFlashcard(String? audio, {Function(dynamic event)? addStreamCompleted}) async {
    try {
      if (audio != null) {
        List<String> audioRegex = audio.split(RegExp(r'_+'));
        String url = await CloudStorage().getAudio(audio: audioRegex);
        if (addStreamCompleted != null) {
          stream = player.playerStateStream.listen(addStreamCompleted);
        }
        await player.setUrl(url);
        await player.play();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void playYay() async {
    try {
      await player.setAsset('assets/audio/yay.mp3');
      await player.setVolume(0.1);
      player.play();
    } catch (e) {
      print('Error: $e');
    }
  }

  void playAlarm() async {
    try {
      await player.setAsset('assets/audio/alarm.mp3');
      await player.setVolume(0.5);
      player.play();
    } catch (e) {
      print('Error: $e');
    }
  }
}
