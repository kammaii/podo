import 'package:get/get.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/values/my_strings.dart';

class WritingController extends GetxController {
  late bool isChecked;


  @override
  void onInit() {
    super.onInit();
    isChecked = LocalStorage().prefs.getBool(MyStrings.iveReadTheFollowing) ?? false;
  }

  setCheckbox(bool? value) {
    isChecked = value!;
    LocalStorage().prefs.setBool(MyStrings.iveReadTheFollowing, isChecked);
    update();
  }

}