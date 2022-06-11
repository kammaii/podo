class LessonCard {
  final String lessonId;
  final int orderId;
  final String type;
  final String? kr;
  final String? en;
  final String? pronun;
  final List<String>? explain;
  final String? audio;
  final String? question;
  final List<String>? examples;

  LessonCard(
    this.lessonId,
    this.orderId,
    this.type, {
    this.kr,
    this.en,
    this.pronun,
    this.explain,
    this.audio,
    this.question,
    this.examples,
  });
}
