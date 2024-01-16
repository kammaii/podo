import 'package:get/get.dart';

class WorkbookController extends GetxController {
  RxInt downloadState = 0.obs; // 1:시작, 2:완료, 3:실패


  void setDownloadState(int state) {
    downloadState.value = state;
  }
}
