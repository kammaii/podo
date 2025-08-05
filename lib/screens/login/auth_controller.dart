import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/fcm_request.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_remote_config.dart';
import 'package:podo/screens/lesson/lesson_course_controller.dart';
import 'package:podo/screens/message/podo_message.dart';
import 'package:podo/screens/my_page/my_page_controller.dart';
import 'package:podo/screens/reading/reading_controller.dart';
import 'package:podo/screens/writing/writing_controller.dart';
import 'package:podo/values/my_strings.dart';
import 'package:podo/screens/my_page/user.dart' as user;

class AuthController extends GetxController {
  final _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _runListener();
  }

  Future<void> getInitData() async {
    MyRemoteConfig();
    await user.User().getUser();
    await LocalStorage().getPrefs();
    final myPageController = Get.find<MyPageController>();
    myPageController.loadThemeMode();
    final courseController = Get.put(LessonCourseController());
    await courseController.loadCourses();
    await PodoMessage().getPodoMessage();
    Get.put(WritingController());
    Get.put(ReadingController());
    Get.toNamed(MyStrings.routeMainFrame);
    if(!courseController.isCourseExist) {
      Get.toNamed(MyStrings.routeLessonCourseList);
    }
    if (user.User().os.isEmpty) {
      String os = '';
      if (Platform.isIOS) {
        os = 'iOS';
      } else if (Platform.isAndroid) {
        os = 'android';
      } else {
        os = 'others';
      }
      Database().updateDoc(collection: 'Users', docId: user.User().id, key: 'os', value: os);
    }
    bool permission = await FcmRequest().getFcmRequest();
    if (user.User().fcmPermission != permission) {
      Database().updateDoc(collection: 'Users', docId: user.User().id, key: 'fcmPermission', value: permission);
      user.User().fcmPermission = permission;
    }
  }

  void _runListener() {
    _auth.authStateChanges().listen((User? user) {
      try {
        if (user != null && user.emailVerified) {
          print('AUTH STATE CHANGES: Email Verified');
          getInitData();
        } else {
          print('AUTH STATE CHANGES: User is null or not verified');
          Get.offNamed(MyStrings.routeLogin);
        }
      } catch (e, stackTrace) {
        final fc = FirebaseCrashlytics.instance;
        fc.log('AuthStateChanges Error');
        if (user != null) {
          fc.setCustomKey('user', user);
          fc.setCustomKey('emailVerified', user.emailVerified);
        } else {
          fc.log('User is null');
        }
        fc.recordError(e, stackTrace);
      }
    });
  }

  Future<void> applyActionCode(String code) async {
    try {
      // oobCode 유효성 확인
      await _auth.checkActionCode(code);

      // 이메일 인증 적용
      await _auth.applyActionCode(code);

      // 상태 최신화
      await _auth.currentUser?.reload();
      User? user = _auth.currentUser;

      if(user != null && user.emailVerified) {
        print('이메일 인증 성공');
        getInitData();
      }
    } catch (e) {
      print('이메일 인증 처리 중 오류 발생: $e');
      Get.back();
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}