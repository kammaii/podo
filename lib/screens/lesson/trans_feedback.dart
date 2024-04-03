import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../my_page/user.dart';

class TransFeedback {

  late String id;
  late String userId;
  late String userName;
  late String lessonTitle;
  late String lessonId;
  late String cardId;
  late String language;
  late String feedback;
  late DateTime date;
  late bool isChecked;

  TransFeedback({required this.lessonId, required this.lessonTitle, required this.cardId, required this.feedback}) {
    id = const Uuid().v4();
    userId = User().id;
    userName = User().name;
    language = User().language;
    date = DateTime.now();
    isChecked = false;
  }

  static const String ID = 'id';
  static const String USER_ID = 'userId';
  static const String USER_NAME = 'userName';
  static const String LESSON_TITLE = 'lessonTitle';
  static const String LESSON_ID = 'lessonId';
  static const String CARD_ID = 'cardId';
  static const String LANGUAGE = 'language';
  static const String FEEDBACK = 'feedback';
  static const String DATE = 'date';
  static const String IS_CHECKED = 'isChecked';

  Map<String, dynamic> toJson() {
    return {
      ID: id,
      USER_ID: userId,
      USER_NAME: userName,
      LESSON_TITLE: lessonTitle,
      LESSON_ID: lessonId,
      CARD_ID: cardId,
      LANGUAGE: language,
      FEEDBACK: feedback,
      DATE: Timestamp.fromDate(date),
      IS_CHECKED: isChecked,
    };
  }
}