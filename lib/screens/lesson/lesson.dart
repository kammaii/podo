class Lesson {

  late String id;
  late String category;
  late Map<String,dynamic> title;
  late bool isFree;
  late bool isReleased;
  String? tag;

  static const String ID = 'id';
  static const String CATEGORY = 'category';
  static const String TITLE = 'title';
  static const String ISFREE = 'isFree';
  static const String ISRELEASED = 'isReleased';
  static const String TAG = 'tag';

  Lesson.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    category = json[CATEGORY];
    title = json[TITLE];
    isFree = json[ISFREE];
    isReleased = json[ISRELEASED];
    tag = json[TAG] ?? null;
  }
}