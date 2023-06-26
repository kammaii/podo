import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/screens/lesson/lesson_course.dart';

class LessonCourseController extends GetxController {

  bool isVisible = false;
  List<List<LessonCourse>> courses = [[],[]];


  Future<void> loadCourses() async {
    final Query query = FirebaseFirestore.instance.collection('LessonCourses');
    List<dynamic> snapshots = await Database().getDocs(query: query);
    courses = [[],[]];
    for(dynamic snapshot in snapshots) {
      LessonCourse course = LessonCourse.fromJson(snapshot.data() as Map<String, dynamic>);
      if(course.isBeginnerMode) {
        courses[0].add(course);
      } else {
        courses[1].add(course);
      }
    }
    courses[0].sort((a,b) => a.orderId.compareTo(b.orderId));
    courses[1].sort((a,b) => a.orderId.compareTo(b.orderId));
    if(LocalStorage().getLessonCourse() == null) {
      isVisible = true;
    }
  }

  setVisibility(bool isVisible) {
    this.isVisible = isVisible;
    update();
  }

}