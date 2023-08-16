class ReadingTitle {

  late String id;
  late int orderId;
  String? image;
  late Map<String,dynamic> title;
  late int level;
  late String category;
  late String tag;
  late bool isReleased;
  late bool isFree;

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String IMAGE = 'image';
  static const String TITLE = 'title';
  static const String LEVEL = 'level';
  static const String CATEGORY = 'category';
  static const String TAG = 'tag';
  static const String ISRELEASED = 'isReleased';
  static const String ISFREE = 'isFree';

  ReadingTitle.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    image = json[IMAGE] ?? null;
    title = json[TITLE];
    level = json[LEVEL];
    category = json[CATEGORY];
    tag = json[TAG] ?? '';
    isReleased = json[ISRELEASED];
    isFree = json[ISFREE];
  }
}