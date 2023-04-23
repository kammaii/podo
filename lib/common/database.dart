import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Database {
  static final Database _instance = Database.init();

  factory Database() {
    return _instance;
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Database.init() {
    print('Database 초기화');
  }

  Future<List<dynamic>> getDocs(
      {required String collection,
        dynamic field,
        dynamic equalTo,
        required String orderBy,
        bool descending = true}) async {
    List<dynamic> documents = [];
    final ref = firestore.collection(collection);
    final queryRef;
    if (field != null) {
      queryRef = ref.where(field, isEqualTo: equalTo).orderBy(orderBy, descending: descending);
    } else {
      queryRef = ref.orderBy(orderBy, descending: descending);
    }
    await queryRef.get().then((QuerySnapshot snapshot) {
      print('quiring');
      for (QueryDocumentSnapshot documentSnapshot in snapshot.docs) {
        documents.add(documentSnapshot.data() as Map<String, dynamic>);
      }
    }, onError: (e) => print('ERROR : $e'));
    return documents;
  }

  Future<List<dynamic>> getListFieldFromDb(
      {required String collection, required String field, required String arrayContains}) async {
    List<dynamic> documents = [];
    final ref = firestore.collection(collection);
    final queryRef;
    queryRef = ref.where(field, arrayContains: arrayContains);
    await queryRef.get().then((QuerySnapshot snapshot) {
      print('quering');
      for (QueryDocumentSnapshot documentSnapshot in snapshot.docs) {
        documents.add(documentSnapshot.data() as Map<String, dynamic>);
      }
    }, onError: (e) => print('ERROR : $e'));
    return documents;
  }

  Future<List<dynamic>> getDocsFromList(
      {required String collection, required String field, required List<dynamic> list}) async {
    List<dynamic> titles = [];
    final ref = firestore.collection(collection).where(field, whereIn: list);
    await ref.get().then((QuerySnapshot snapshot) {
      print('Get docs from list');
      for (QueryDocumentSnapshot documentSnapshot in snapshot.docs) {
        titles.add(documentSnapshot.data() as Map<String, dynamic>);
      }
    });
    return titles;
  }

  Future<void> setDoc({required String collection, required dynamic doc}) async {
    DocumentReference ref = firestore.collection(collection).doc(doc.id);
    return await ref.set(doc.toJson()).then((value) {
      print('Document is Saved');
      Get.snackbar('Document is saved', 'id: ${doc.id}', snackPosition: SnackPosition.BOTTOM);
    }).catchError((e) => print(e));
  }

  Future<void> updateField(
      {required String collection, required String docId, required Map<String, dynamic> map}) async {
    DocumentReference ref = firestore.collection(collection).doc(docId);
    return await ref.update(map).then((value) {
      print('Updated');
      Get.snackbar('Updated', 'id: ${docId}', snackPosition: SnackPosition.BOTTOM);
    }).catchError((e) => print(e));
  }

  Future<void> switchOrderTransaction(
      {required String collection, required String docId1, required String docId2}) async {
    await firestore.runTransaction((transaction) async {
      final ref1 = firestore.collection(collection).doc(docId1);
      final ref2 = firestore.collection(collection).doc(docId2);
      final doc1 = await transaction.get(ref1);
      final doc2 = await transaction.get(ref2);
      final doc1Index = doc1.get('orderId');
      final doc2Index = doc2.get('orderId');
      print('Transaction updating');
      transaction.update(ref1, {'orderId': doc2Index});
      transaction.update(ref2, {'orderId': doc1Index});
    }).then((value) {
      print('Transaction completed');
      Get.snackbar('Transaction completed', '',
          snackPosition: SnackPosition.BOTTOM);
    }).onError((e, stackTrace) {
      Get.snackbar('에러', e.toString(), snackPosition: SnackPosition.BOTTOM);
    });
  }

  Future<void> addValueTransaction(
      {required String collection,
        required String docId,
        required String field,
        required dynamic addValue}) async {
    firestore.runTransaction((transaction) async {
      final ref = firestore.collection(collection).doc(docId);
      final doc = await transaction.get(ref);
      final newValue = doc.get(field);
      newValue.add(addValue);
      print('Transaction updating');
      transaction.update(ref, {field: newValue});
    }).then((_) {
      print('Transaction completed');
      Get.snackbar('레슨이 추가되었습니다.', addValue, snackPosition: SnackPosition.BOTTOM);
    }).onError((e, stackTrace) {
      Get.snackbar('에러', e.toString(), snackPosition: SnackPosition.BOTTOM);
    });
  }

  Future<void> deleteLessonFromDb({required String collection, required dynamic lesson}) async {
    DocumentReference ref = firestore.collection(collection).doc(lesson.id);
    return await ref.delete().then((value) {
      print('Lesson is Deleted');
      Get.snackbar('Lesson is Deleted', 'id: ${lesson.id}', snackPosition: SnackPosition.BOTTOM);
    }).catchError((e) => print(e));
  }
}