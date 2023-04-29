class FlashCard {

  late String id;
  late String? ko;
  late String? fo;

  static const String ID = 'id';
  static const String KO = 'ko';
  static const String FO = 'fo';

  FlashCard.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    ko = json[KO];
    fo = json[FO];
  }
}