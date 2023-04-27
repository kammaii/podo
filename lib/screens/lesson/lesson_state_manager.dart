import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class LessonStateManager extends GetxController {
  late AudioPlayer player;
  late Duration currentPosition;
  Duration? duration;
  late double audioProgress;
  late List<bool> audioSpeedToggle;

  @override
  void onInit() {
    super.onInit();
    player = AudioPlayer();
    audioProgress = 0.0;
    duration = const Duration(seconds: 0);
    currentPosition = const Duration(seconds: 0);
    audioSpeedToggle = [true, false];
  }

  void setAudioUrlAndPlay({required String url}) async {
    print('SETTING URL');
    duration = await player.setUrl(url);
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
    playAudio();
  }

  void playAudio() async {
    print('PLAYING AUDIO');
    await player.seek(Duration.zero);
    await player.setVolume(1);
    await player.setSpeed(audioSpeedToggle[0] ? 1 : 0.8);
    player.play();
  }

  void changeAudioSpeedToggle({required bool isNormal}) {
    audioSpeedToggle[0] = isNormal;
    audioSpeedToggle[1] = !isNormal;
    playAudio();
    update();
  }

  void initAudio() {
    player.dispose();
    player = AudioPlayer();
    player.positionStream.listen((position) {
      currentPosition = position;
      if (duration!.inMilliseconds > 0) {
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
        //audioProgress = 0;
        //update();
      }
    });
    audioProgress = 0.0;
    duration = const Duration(seconds: 0);
    currentPosition = const Duration(seconds: 0);
  }
}
