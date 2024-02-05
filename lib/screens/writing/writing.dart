import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/screens/writing/writing_question.dart';
import 'package:uuid/uuid.dart';

class Writing {
  late String id;
  late String questionId;
  late String questionTitle;
  late int questionLevel;
  late String userId;
  String? userName;
  String? fcmToken;
  late String userWriting;
  late String correction;
  late DateTime dateWriting;
  DateTime? dateReply;
  late int status;
  String? comments;

  Writing(WritingQuestion question) {
    id = const Uuid().v4();
    questionId = question.id;
    questionTitle = question.title['ko'];
    questionLevel = question.level;
    userId = User().id;
    userName = User().name;
    fcmToken = User().fcmToken;
    correction = '';
    dateWriting = DateTime.now();
    status = 0;
  }

  static const String ID = 'id';
  static const String QUESTIONID = 'questionId';
  static const String QUESTIONTITLE = 'questionTitle';
  static const String QUESTIONLEVEL = 'questionLevel';
  static const String USERID = 'userId';
  static const String USERNAME = 'userName';
  static const String FCMTOKEN = 'fcmToken';
  static const String USERWRITING = 'userWriting';
  static const String CORRECTION = 'correction';
  static const String DATEWRITING = 'dateWriting';
  static const String DATEREPLY = 'dateReply';
  static const String STATUS = 'status';
  static const String COMMENTS = 'comments';

  Writing.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    questionId = json[QUESTIONID];
    questionTitle = json[QUESTIONTITLE];
    questionLevel = json[QUESTIONLEVEL];
    userId = json[USERID];
    userName = json[USERNAME];
    userWriting = json[USERWRITING];
    correction = json[CORRECTION];
    Timestamp writingStamp = json[DATEWRITING];
    dateWriting = writingStamp.toDate();
    if (json[DATEREPLY] != null) {
      Timestamp replyStamp = json[DATEREPLY];
      dateReply = replyStamp.toDate();
    }
    status = json[STATUS];
    if (json[COMMENTS] != null) {
      comments = json[COMMENTS];
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      QUESTIONID: questionId,
      QUESTIONTITLE: questionTitle,
      QUESTIONLEVEL: questionLevel,
      USERID: userId,
      USERNAME: userName,
      FCMTOKEN: fcmToken,
      USERWRITING: userWriting,
      CORRECTION: correction,
      DATEWRITING: Timestamp.fromDate(dateWriting),
      STATUS: status,
    };
    if(dateReply != null) {
      map[DATEREPLY] = Timestamp.fromDate(dateReply!);
    }
    return map;
  }
}