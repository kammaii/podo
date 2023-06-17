import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Feedback {
  late String id;
  late String email;
  late String userId;
  late String message;
  late DateTime date;

  Feedback() {
    id = const Uuid().v4();
    date = DateTime.now();
  }

  static const String ID = 'id';
  static const String EMAIL = 'email';
  static const String USERID = 'userId';
  static const String MESSAGE = 'message';
  static const String DATE = 'date';

  Map<String, dynamic> toJson() => {
        ID: id,
        EMAIL: email,
        USERID: userId,
        MESSAGE: message,
        DATE: Timestamp.fromDate(date),
      };
}
