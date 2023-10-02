import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:podo/screens/my_page/user.dart';

class LessonCourseController extends GetxController {

  bool isVisible = false;
  List<List<LessonCourse>> courses = [[],[]];

  Future<void> loadCourses() async {
    bool isAdmin = User().email == User().admin;
    final Query query;
    if(isAdmin) {
      query = FirebaseFirestore.instance.collection('LessonCourses');
    } else {
      query = FirebaseFirestore.instance.collection('LessonCourses').where('isReleased', isEqualTo: true);
    }
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
    bool isCourseExist = false;
    if(course != null) {
      isCourseExist = checkExist(course.id);
    }
    if(!isCourseExist) {
      isVisible = true;
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

  setVisibility(bool isVisible) {
    this.isVisible = isVisible;
    update();
  }
}