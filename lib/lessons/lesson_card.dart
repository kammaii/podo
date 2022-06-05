class LessonCard {
  String lessonId;
  String itemId;
  late String uniqueId;
  String type;
  String? kr;
  String? en;
  String? pronun;
  List<String>? explain;
  String? audio;
  String? question;
  List<String>? examples;

  LessonCard(
    this.lessonId,
    this.itemId,
    this.type, {
    this.kr,
    this.en,
    this.pronun,
    this.explain,
    this.audio,
    this.question,
    this.examples,
  }) {
    uniqueId = '${lessonId}_$itemId';
  }
}
