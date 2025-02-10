import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:podo/screens/reading/reading_title.dart';

class KoreanBiteController extends GetxController {
  RxMap<dynamic, dynamic> hasFlashcard = {}.obs;
  RxMap<dynamic, dynamic> hasLike = {}.obs;
  RxMap<dynamic, dynamic> isCompleted = {}.obs;
}