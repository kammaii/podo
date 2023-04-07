class LessonCourse {
  late String id;
  late int orderId;
  String? image;
  late Map<String,dynamic> course;
  late Map<String,dynamic> description;
  late bool isBeginnerMode;
  String? tag;
  late List<dynamic> lessons;
  late bool isReleased;

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String IMAGE = 'image';
  static const String COURSE = 'course';
  static const String DESCRIPTION = 'description';
  static const String ISBEGINNERMODE = 'isBeginnerMode';
  static const String TAG = 'tag';
  static const String LESSONS = 'lessons';
  static const String ISRELEASED = 'isReleased';

  LessonCourse.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    image = json[IMAGE] ?? null;
    course = json[COURSE];
    description = json[DESCRIPTION];
    isBeginnerMode = json[ISBEGINNERMODE];
    tag = json[TAG] ?? null;
    lessons = json[LESSONS];
    isReleased = json[ISRELEASED];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      ORDERID: orderId,
      COURSE: course,
      DESCRIPTION: description,
      ISBEGINNERMODE: isBeginnerMode,
      LESSONS: lessons,
      ISRELEASED: isReleased
    };
    map[IMAGE] = image ?? null;
    map[TAG] = tag ?? null;
    return map;
  }
}