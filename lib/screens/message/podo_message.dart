import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo/common/database.dart';

class PodoMessage {
  PodoMessage._init();
  static final PodoMessage _instance = PodoMessage._init();

  factory PodoMessage() {
    return _instance;
  }

  String? id;
  Map<String, dynamic>? title;
  String? content;
  DateTime? dateStart;
  DateTime? dateEnd;
  bool isActive = false;
  late bool hasBestReply;

  static const String ID = 'id';
  static const String TITLE = 'title';
  static const String CONTENT = 'content';
  static const String DATE_START = 'dateStart';
  static const String DATE_END = 'dateEnd';
  static const String IS_ACTIVE = 'isActive';
  static const String HAS_BEST_REPLY = 'hasBestReply';

  samplePodoMessage() {
    id = '09f6218a-6fa9-4318-9f27-73503787491c';
    dateStart = DateTime.now();
    dateEnd = dateStart!.add(const Duration(days: 2));
    title = {'en': 'what kind of food do you like?', 'ko': '어떤 음식을 좋아해요?'};
    isActive = true;
    hasBestReply = false;
  }

  Future<void> getPodoMessage() async {
    final Query query = FirebaseFirestore.instance.collection('PodoMessages').where('isActive', isEqualTo: true);
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
      isActive = json[IS_ACTIVE];
      hasBestReply = json[HAS_BEST_REPLY];
    } else {
      id = null;
      isActive = false;
    }
  }
}
