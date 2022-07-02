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

  Message({
    required this.msgId,
    required this.msg,
    required this.tag,
    required this.userEmail,
    required this.reply,
    required this.sendTime,
    required this.replyTime,
    this.isBestQuestion,
    this.notificationId,
  });
}
