class LessonItem {

  String lessonId;
  String title;
  bool isVideoLesson;
  bool isCompleted;

  LessonItem(this.lessonId, this.title, {this.isVideoLesson = false, this.isCompleted = false});
}