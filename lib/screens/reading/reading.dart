class Reading {

  late String id;
  late int orderId;
  late Map<String,dynamic> title;
  late int level;
  late String category;
  late String tag;
  late String image;
  late Map<String, dynamic> content;
  late Map<String, dynamic> words;
  late bool isReleased;
  late bool isFree;
  late List<String> audio;

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String TITLE = 'title';
  static const String LEVEL = 'level';
  static const String CATEGORY = 'category';
  static const String TAG = 'tag';
  static const String IMAGE = 'image';
  static const String CONTENT = 'content';
  static const String WORDS = 'words';
  static const String ISRELEASED = 'isReleased';
  static const String ISFREE = 'isFree';
  static const String AUDIO = 'audio';

  Reading.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    title = json[TITLE];
    level = json[LEVEL];
    category = json[CATEGORY];
    tag = json[TAG] ?? '';
    image = json[IMAGE];
    content = json[CONTENT];
    words = json[WORDS];
    isReleased = json[ISRELEASED];
    isFree = json[ISFREE];
    audio = json[AUDIO];
  }
}