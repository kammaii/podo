import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/screens/login/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeepLinks extends GetxController {

  @override
  void onInit() {
    super.onInit();
    handleDeepLinks();
  }

  void runDeepLink(Uri? deepLink) async {
    print('딥링크 실행');

    if (deepLink == null) return;

    Uri uri = Uri.parse(deepLink.toString());
    String? mode = uri.queryParameters['mode'];
    String? path = uri.queryParameters['path'];

    print('MODE: $mode');
    print('PATH: $path');

    if (path != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('path', path);
    }

    if (mode == 'verifyEmail') {
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      final authController = Get.find<AuthController>();
      await authController.verifyEmail();
      Get.back();
    }
  }

  Future<void> handleDeepLinks() async {
    // 앱 실행 중 딥링크 수신
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen((Uri? uri) {
      print('앱 실행 중 딥링크 수신');
      runDeepLink(uri);
    }).onError((e) {
      print('딥링크 에러: $e');
    });

    // 앱이 처음 열렸을 때 딥링크 수신
    appLinks.getInitialLink().then((Uri? uri) {
      print('앱 처음 실행 후 딥링크 수신');
      runDeepLink(uri);
    }).catchError((e) {
      print('딥링크 에러: $e');
    });
  }
}