class Reading {

  late String id;
  late int orderId;
  late Map<String, dynamic> content;
  late Map<String, dynamic> words;

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String CONTENT = 'content';
  static const String WORDS = 'words';

  Reading.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    content = json[CONTENT];
    words = json[WORDS];
  }
}