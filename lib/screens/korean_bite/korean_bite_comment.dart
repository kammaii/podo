import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo/screens/my_page/user.dart';

class KoreanBiteComment {

  late String id;
  late String userId;
  late String userImage;
  late String userName;
  late String comment;
  late int likes;
  List<String> likedBy = [];
  String? parentId;
  List<KoreanBiteComment>? replies;
  late DateTime date;

  static const String ID = 'id';
  static const String USER_ID = 'userId';
  static const String USER_IMAGE = 'userImage';
  static const String USER_NAME = 'userName';
  static const String COMMENT = "comment";
  static const String LIKES = 'likes';
  static const String LIKED_BY = 'likedBy';
  static const String PARENT_ID = 'parentId';
  static const String REPLIES = 'replies';
  static const String DATE = 'date';

  KoreanBiteComment.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    userId = json[USER_ID];
    if(json[USER_IMAGE] != null) {
      userImage = json[USER_IMAGE];
    }
    userName = json[USER_NAME] ?? 'User #${User().id.substring(0,5)}';
    comment = json[COMMENT];
    likes = json[LIKES];
    likedBy = json[LIKED_BY];
    if(json[PARENT_ID] != null) {
      parentId = json[PARENT_ID];
    }
    if(json[REPLIES] != null) {
      replies = (json[REPLIES] as List<dynamic>)
          .map((reply) => KoreanBiteComment.fromJson(reply as Map<String, dynamic>))
          .toList();
    }
    Timestamp stamp = json[DATE];
    date = stamp.toDate();
  }
}