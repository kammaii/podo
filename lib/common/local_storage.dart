import 'dart:convert';

import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage.init();
  late final SharedPreferences prefs;
  final LESSON_COURSE = 'lessonCourse';
  bool isInit = false;

  factory LocalStorage() {
    return _instance;
  }

  LocalStorage.init() {
    print('LocalStorage 초기화');
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    isInit = true;
  }

  void setLessonCourse(LessonCourse course) {
    prefs.setString(LESSON_COURSE, jsonEncode(course.toJson()));
  }

  LessonCourse? getLessonCourse() {
    if (isInit) {
      String? json = prefs.getString(LESSON_COURSE);
      if (json != null) {
        return LessonCourse.fromJson(jsonDecode(json));
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}
