
class LessonTitle {
  LessonTitle(this.level, this.orderId, this.category, this.title, {this.isVideo}) {
    lessonId = '${level}_${orderId.toString()}';
  }

  late final String lessonId;
  final String level;
  final int orderId;
  final String category;
  final String title;
  final bool? isVideo;
}