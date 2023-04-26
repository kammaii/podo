import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';

class PlayAudio {

  static final PlayAudio _instance = PlayAudio.init();

  factory PlayAudio() {
    return _instance;
  }

  AudioPlayer player = AudioPlayer();

  PlayAudio.init() {
    debugPrint('playAudio 초기화');
  }

  void setUrl({required String url}) async {
    print('SETTING URL : $url');
    await player.setUrl(url).then((value) => playAudio());
  }

  // void setUrls({required List<dynamic> audios}) async {
  //   List<AudioSource> sources = [];
  //   for(Map<String,String> audio in audios) {
  //     sources.add(AudioSource.uri(Uri.parse(audio['url']!)));
  //   }
  //   await player.setAudioSource(ConcatenatingAudioSource(children: sources));
  // }

  // void playAudioIndex(int index) {
  //   print('PLAY AUDIO');
  //   player.seek(Duration.zero, index: index);
  //   player.play();
  // }

  void playAudio() async {
    print('PLAYING AUDIO');
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