import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:podo/common/database.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:podo/common/history.dart';
import 'package:podo/screens/lesson/lesson_course_controller.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage.init();
  SharedPreferences? prefs;
  late String LESSON_COURSE;
  late String FLASHCARDS;
  late String HISTORIES;
  late String REF_FLASHCARD;
  late String REF_HISTORY;
  late String LESSON_SCROLL_POSITION;
  bool isInit = false;
  List<FlashCard> flashcards = [];
  List<History> histories = [];
  late CollectionReference flashcardRef;
  late CollectionReference historyRef;
  bool hasPrefs = false;
  bool hasWelcome = false;

  factory LocalStorage() {
    return _instance;
  }

  LocalStorage.init() {
    print('LocalStorage 초기화');
  }

  Future<void> getPrefs() async {
    prefs ??= await SharedPreferences.getInstance();
    if (!isInit) {
      isInit = true;
      await getFlashcards();
      await getHistories();
    }
  }

  void setLessonCourse(LessonCourse course, {bool resetPosition = false}) {
    prefs!.setString(LESSON_COURSE, jsonEncode(course.toJson()));
    if(resetPosition) {
      setLessonScrollPosition(0);
    }
  }

  LessonCourse? getLessonCourse() {
    LESSON_COURSE = '${User().id}/lessonCourse';
    String? json = prefs!.getString(LESSON_COURSE);
    if (json != null) {
      return LessonCourse.fromJson(jsonDecode(json));
    } else {
      return null;
    }
  }

  void setLessonScrollPosition(double position) {
    prefs!.setDouble(LESSON_SCROLL_POSITION, position);
  }

  double getLessonScrollPosition() {
    LESSON_SCROLL_POSITION = '${User().id}/lessonScrollPosition';
    return prefs!.getDouble(LESSON_SCROLL_POSITION) ?? 0;
  }

  bool hasFlashcard({required String itemId}) {
    return flashcards.any((flashcard) => flashcard.itemId == itemId);
  }

  void setFlashcards() {
    List<String> flashcardsString = flashcards.map((e) => jsonEncode(e.toJson(isLocal: true))).toList();
    prefs!.setStringList(FLASHCARDS, flashcardsString);
  }

  void convertLocalFlashcards(List<String> localFlashcards) {
    flashcards = localFlashcards.map((e) => FlashCard.fromJson(jsonDecode(e), isLocal: true)).toList();
    flashcards.sort((a, b) => b.date.compareTo(a.date));
  }

  void downloadFlashcards() async {
    Query query = flashcardRef.orderBy('date', descending: true);
    List<dynamic> snapshots = await Database().getDocs(query: query);
    flashcards.clear();
    for (dynamic snapshot in snapshots) {
      flashcards.add(FlashCard.fromJson(snapshot.data() as Map<String, dynamic>));
    }
    setFlashcards();
    print('플래시카드 다운로드');
  }

  void uploadFlashcards() async {
    for (final card in flashcards) {
      await Database().setDoc(collection: REF_FLASHCARD, doc: card);
    }
    print('플래시카드 업로드');
  }

  Future<void> getFlashcards() async {
    FLASHCARDS = '${User().id}/flashcards';
    REF_FLASHCARD = 'Users/${User().id}/FlashCards';
    flashcardRef = FirebaseFirestore.instance.collection(REF_FLASHCARD);
    List<String>? localFlashcards = prefs!.getStringList(FLASHCARDS);
    flashcards = [];
    DateTime? dateOnDB;
    Query query = flashcardRef.orderBy('date', descending: true).limit(1);
    List<dynamic> snapshots = await Database().getDocs(query: query);
    if (snapshots.isNotEmpty) {
      dateOnDB = FlashCard.fromJson(snapshots.first.data() as Map<String, dynamic>).date;
    }

    // 로컬: null && DB: null  ||  로컬 date == DB date -> return;
    // 로컬: null && DB: !null -> DB 에서 다운로드
    if (localFlashcards == null && dateOnDB != null) {
      downloadFlashcards();
    }

    // 로컬: !null && DB: !null -> Date 비교
    if (localFlashcards != null && dateOnDB != null) {
      convertLocalFlashcards(localFlashcards);
      int compareDate = flashcards.first.date.compareTo(dateOnDB);

      // 로컬 < DB -> DB 에서 다운로드
      if (compareDate < 0) {
        downloadFlashcards();

        // 로컬 > DB -> 로컬을 DB에 업로드
      } else if (compareDate > 0) {
        uploadFlashcards();
      }
    }

    // 로컬: !null && DB == null -> 로컬을 DB에 업로드
    if (localFlashcards != null && dateOnDB == null) {
      convertLocalFlashcards(localFlashcards);
      uploadFlashcards();
    }
    return;
  }

  bool hasHistory({required String itemId}) {
    return histories.any((flashcard) => flashcard.itemId == itemId);
  }

  void convertLocalHistories(List<String> localHistories) {
    histories = localHistories.map((e) => History.fromJson(jsonDecode(e), isLocal: true)).toList();
  }

  void setHistories() {
    List<String> historiesString = histories.map((e) => jsonEncode(e.toJson(isLocal: true))).toList();
    prefs!.setStringList(HISTORIES, historiesString);
  }

  void downloadHistories() async {
    Query query = historyRef.orderBy('date', descending: true);
    List<dynamic> snapshots = await Database().getDocs(query: query);
    histories.clear();
    for (dynamic snapshot in snapshots) {
      histories.add(History.fromJson(snapshot.data() as Map<String, dynamic>));
    }
    setHistories();
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if(fcmToken != null) {
      Database().updateDoc(collection: 'Users', docId: User().id, key: 'fcmToken', value: fcmToken);
    }
    print('히스토리 다운로드');
  }

  void uploadHistories() async {
    for (final history in histories) {
      await Database().setDoc(collection: REF_HISTORY, doc: history);
    }
    print('히스토리 업로드');
  }

  Future<void> getHistories() async {
    HISTORIES = '${User().id}/histories';
    REF_HISTORY = 'Users/${User().id}/Histories';
    historyRef = FirebaseFirestore.instance.collection(REF_HISTORY);
    List<String>? localHistories = prefs!.getStringList(HISTORIES);
    histories = [];
    DateTime? dateOnDB;
    Query query = historyRef.orderBy('date', descending: true).limit(1);
    List<dynamic> snapshots = await Database().getDocs(query: query);
    if (snapshots.isNotEmpty) {
      dateOnDB = History.fromJson(snapshots.first.data() as Map<String, dynamic>).date;
    }

    if (localHistories == null && dateOnDB != null) {
      downloadHistories();
    }

    if (localHistories != null && dateOnDB != null) {
      convertLocalHistories(localHistories);
      int compareDate = histories.first.date.compareTo(dateOnDB);

      if (compareDate < 0) {
        downloadHistories();
      } else if (compareDate > 0) {
        uploadHistories();
      }
    }

    if (localHistories != null && dateOnDB == null) {
      convertLocalHistories(localHistories);
      uploadHistories();
    }
    return;
  }
}
