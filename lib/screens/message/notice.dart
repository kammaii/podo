class PopUp {
  final String popUpId;
  final String tag;
  final String title;
  final Map<String, String> contents;
  final bool isOnBoard;
  final int? deadline;
  final String? image;
  final String? audio;
  final List<String>? ranking;

  PopUp(
    this.popUpId,
    this.tag,
    this.title,
    this.contents,
    this.isOnBoard, {
    this.deadline,
    this.image,
    this.audio,
    this.ranking,
  });
}
