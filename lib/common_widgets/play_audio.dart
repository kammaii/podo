import 'package:just_audio/just_audio.dart';

class PlayAudio {

  static final PlayAudio _instance = PlayAudio.init();

  factory PlayAudio() {
    return _instance;
  }

  AudioPlayer player = AudioPlayer();

  PlayAudio.init() {
    print('playAudio 초기화');
  }

  void setAudios(String lessonId) {
    //todo: 해당 레슨의 모든 오디오를 미리 불러와서 저장하기
  }

  void playAudio(String audio) async {
    await player.setAsset('assets/audio/$audio');
    await player.setVolume(1);
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