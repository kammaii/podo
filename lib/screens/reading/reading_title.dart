import 'package:cloud_firestore/cloud_firestore.dart';

class ReadingTitle {

  late String id;
  String? image;
  late Map<String,dynamic> title;
  late int level;
  late String category;
  late String tag;
  late bool isReleased;
  late bool isFree;
  Map<String,dynamic>? summary;
  DateTime? date; // Favorite Readings 정렬용

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String IMAGE = 'image';
  static const String TITLE = 'title';
  static const String LEVEL = 'level';
  static const String CATEGORY = 'category';
  static const String TAG = 'tag';
  static const String ISRELEASED = 'isReleased';
  static const String ISFREE = 'isFree';
  static const String SUMMARY = 'summary';
  static const String DATE = 'date';

  ReadingTitle.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    image = json[IMAGE] ?? null;
    title = json[TITLE];
    level = json[LEVEL];
    category = json[CATEGORY];
    tag = json[TAG] ?? '';
    isReleased = json[ISRELEASED] ?? false;
    isFree = json[ISFREE];
    if(json[SUMMARY] != null) {
      summary = json[SUMMARY];
    }
    if(json[DATE] != null) {
      Timestamp replyStamp = json[DATE];
      date = replyStamp.toDate();
    }
  }

  // Favorite 읽기 저장용
  Map<String, dynamic> toJson() => {
    ID: id,
    IMAGE: image ?? null,
    TITLE: title,
    LEVEL: level,
    CATEGORY: category,
    TAG: tag,
    ISFREE: isFree,
    SUMMARY: summary ?? null,
    DATE: DateTime.now(),
  };
}