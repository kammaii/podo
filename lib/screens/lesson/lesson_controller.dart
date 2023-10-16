import 'package:get/get.dart';
import 'package:podo/common/play_audio.dart';

class LessonController extends GetxController {
  late Duration currentPosition;
  Duration? duration;
  late double audioProgress;
  late List<bool> audioSpeedToggle;
  RxMap<dynamic, dynamic> hasFlashcard = {}.obs;
  RxMap<dynamic, dynamic> isCompleted = {}.obs;

  @override
  void onInit() {
    super.onInit();
    audioProgress = 0.0;
    duration = const Duration(seconds: 0);
    currentPosition = const Duration(seconds: 0);
    audioSpeedToggle = [true, false];
  }

  bool getIsCompleted(String lessonId) {
    bool b = isCompleted[lessonId] ?? false;
    return b;
  }

  void setAudioPathAndPlay({required String path}) async {
    print('SETTING URL');
    duration = await PlayAudio().player.setFilePath(path);
    PlayAudio().player.positionStream.listen((position) {
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
    await PlayAudio().player.seek(Duration.zero);
    await PlayAudio().player.setVolume(1);
    await PlayAudio().player.setSpeed(audioSpeedToggle[0] ? 1 : 0.8);
    PlayAudio().player.play();
  }

  void changeAudioSpeedToggle({required bool isNormal}) {
    audioSpeedToggle[0] = isNormal;
    audioSpeedToggle[1] = !isNormal;
    playAudio();
    update();
  }
}
