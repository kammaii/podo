import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/screens/message/podo_message.dart';

class PodoMessageController extends GetxController {
  RxMap<dynamic, dynamic> hasFlashcard = {}.obs;
  RxBool isPlaying = false.obs;
  String? podoMsgBtnText;
  RxBool podoMsgBtnActive = true.obs;
  late bool hasExpired;
  late bool hasReplied;

  setPodoMsgBtn() {
    DateTime now = DateTime.now();
    hasExpired = now.isAfter(PodoMessage().dateEnd!);
    hasReplied = LocalStorage().hasHistory(itemId: PodoMessage().id!);

    if(hasExpired) {
      podoMsgBtnText = tr('expired');
      podoMsgBtnActive.value = false;
    } else if(hasReplied) {
      podoMsgBtnText = tr('replied');
      podoMsgBtnActive.value = false;
    } else {
      podoMsgBtnText = tr('replyPodo');
      podoMsgBtnActive.value = true;
    }
  }
}
