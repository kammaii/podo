class Lesson {

  late String id;
  late String type;
  late Map<String,dynamic> title;
  late bool isReleased;
  String? tag;
  late bool hasOptions;
  late bool isFree;
  bool? isFreeOptions;
  String? speakingId;
  String? readingId;
  late bool isSpeakingReleased;
  late bool isReadingReleased;
  late bool adFree; // 광고 제거 (For 한글,한자 레슨 Intro)
  String? courseTitle; // Grammar 모드에서 검색으로 레슨을 실행 시 logEvent 입력용.

  static const String ID = 'id';
  static const String TYPE = 'type';
  static const String TITLE = 'title';
  static const String ISRELEASED = 'isReleased';
  static const String TAG = 'tag';
  static const String HAS_OPTIONS = 'hasOptions';
  static const String IS_FREE = 'isFree';
  static const String IS_FREE_OPTIONS = 'isFreeOptions';
  static const String SPEAKING_ID = 'speakingId';
  static const String READING_ID = 'readingId';
  static const String IS_SPEAKING_RELEASED = 'isSpeakingReleased';
  static const String IS_READING_RELEASED = 'isReadingReleased';
  static const String AD_FREE = 'adFree';

  Lesson.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    type = json[TYPE];
    title = json[TITLE];
    isReleased = json[ISRELEASED];
    tag = json[TAG] ?? null;
    hasOptions = json[HAS_OPTIONS];
    isFree = json[IS_FREE];
    if(json[IS_FREE_OPTIONS] != null) {
      isFreeOptions = json[IS_FREE_OPTIONS];
    }
    if(json[SPEAKING_ID] != null) {
      speakingId = json[SPEAKING_ID];
    }
    if(json[READING_ID] != null) {
      readingId = json[READING_ID];
    }
    isReadingReleased = json[IS_READING_RELEASED] ?? false;
    isSpeakingReleased = json[IS_SPEAKING_RELEASED] ?? false;
    adFree = json[AD_FREE] ?? false;
  }
}