import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo/common/database.dart';

class CloudMessage {
  CloudMessage._init();
  static final CloudMessage _instance = CloudMessage._init();

  factory CloudMessage() {
    return _instance;
  }

  String? id;
  Map<String, dynamic>? title;
  String? content;
  DateTime? dateStart;
  DateTime? dateEnd;
  bool? isInDate;

  static const String ID = 'id';
  static const String TITLE = 'title';
  static const String CONTENT = 'content';
  static const String DATE_START = 'dateStart';
  static const String DATE_END = 'dateEnd';

  Future<void> getCloudMessage() async {
    final Query query = FirebaseFirestore.instance.collection('CloudMessages').where('isActive', isEqualTo: true);
    List<dynamic> snapshots = await Database().getDocs(query: query);
    if(snapshots.isNotEmpty) {
      final json = snapshots[0].data();
      id = json[ID];
      title = json[TITLE];
      content = json[CONTENT];
      Timestamp stamp = json[DATE_START];
      dateStart = stamp.toDate();
      stamp = json[DATE_END];
      dateEnd = stamp.toDate();
      DateTime now = DateTime.now();
      (now.isAfter(dateStart!) && now.isBefore(dateEnd!)) ? isInDate = true : isInDate = false;
    }
  }
}
