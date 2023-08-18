import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/values/my_strings.dart';

class WritingController extends GetxController {
  late bool isChecked;
  late RxInt leftRequestCount = 0.obs;
  int maxRequestCount = 3;
  RxBool isLoading = false.obs;
  RxList<bool> hasFlashcard = <bool>[].obs;


  @override
  void onInit() {
    super.onInit();
    isChecked = LocalStorage().prefs!.getBool(tr('iveReadTheFollowing')) ?? false;
  }

  setCheckbox(bool? value) {
    isChecked = value!;
    LocalStorage().prefs!.setBool(tr('iveReadTheFollowing'), isChecked);
    update();
  }

}