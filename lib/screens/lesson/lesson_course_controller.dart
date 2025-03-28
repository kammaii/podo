import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/values/my_strings.dart';

class LessonCourseController extends GetxController {

  List<List<LessonCourse>> courses = [[],[]];
  bool isCourseExist = false;

  Future<void> loadCourses() async {
    final Query query = FirebaseFirestore.instance.collection('LessonCourses').where('isReleased', isEqualTo: true);
    List<dynamic> snapshots = await Database().getDocs(query: query);
    courses = [[],[]];
    for(dynamic snapshot in snapshots) {
      LessonCourse course = LessonCourse.fromJson(snapshot.data() as Map<String, dynamic>);
      if(course.isTopicMode) {
        courses[0].add(course);
      } else {
        courses[1].add(course);
      }
    }
    courses[0].sort((a,b) => a.orderId.compareTo(b.orderId));
    courses[1].sort((a,b) => a.orderId.compareTo(b.orderId));
    LessonCourse? course = LocalStorage().getLessonCourse();

    if(course != null) {
      isCourseExist = checkExist(course.id);
    }
  }

  bool checkExist(String id) {
    for(List<LessonCourse> list in courses) {
      for(LessonCourse course in list) {
        if(course.id == id) {
          LocalStorage().setLessonCourse(course);
          return true;
        }
      }
    }
    return false;
  }
}