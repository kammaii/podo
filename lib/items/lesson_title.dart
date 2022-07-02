class LessonTitle {
  LessonTitle({
    required this.level,
    required this.orderId,
    required this.category,
    required this.title,
    this.isVideo,
  }) {
    lessonId = '${level}_${orderId.toString()}';
  }

  late final String lessonId;
  final String level;
  final int orderId;
  final String category;
  final String title;
  final bool? isVideo;
}
