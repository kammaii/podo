class Message {
  final String msgId;
  final String msg;
  final String tag;
  final String userEmail;
  final String reply;
  final DateTime sendTime;
  final DateTime replyTime;
  final bool? isBestQuestion;
  final String? notificationId;

  Message(
    this.msgId,
    this.msg,
    this.tag,
    this.userEmail,
    this.reply,
    this.sendTime,
    this.replyTime, {
    this.isBestQuestion,
    this.notificationId,
  });
}
