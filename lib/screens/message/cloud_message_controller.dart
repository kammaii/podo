import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podo/common/play_audio.dart';

class CloudMessageController extends GetxController {
  RxBool hasReplied = false.obs;
  RxList<bool> hasFlashcard = <bool>[].obs;


  setHasReplied(bool b) {
    hasReplied.value = b;
  }
}
