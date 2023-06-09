import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/flashcard/flashcard_controller.dart';
import 'package:podo/screens/profile/user_info.dart';
import 'package:podo/values/my_strings.dart';

class Database {
  static final Database _instance = Database.init();

  factory Database() {
    return _instance;
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Database.init() {
    print('Database 초기화');
  }

  Future<void> setFlashcard({required FlashCard flashCard}) async {
    final collection = 'Users/${User().email}/FlashCards';
    final ref = firestore.collection(collection).where('front', isEqualTo: flashCard.front);
    QuerySnapshot snapshot = await ref.get();
    if (snapshot.docs.isEmpty) {
      setDoc(collection: collection, doc: flashCard, completeMention: MyStrings.flashcardSave);
    } else {
      Get.snackbar(MyStrings.haveFlashcard, '');
    }
  }

  Future<void> updateFlashcard({required String id, required String front, required String back}) async {
    final collection = 'Users/${User().email}/FlashCards';
    DocumentReference ref = firestore.collection(collection).doc(id);
    return await ref.update({'front': front, 'back': back}).then((value) {
      Get.find<FlashCardController>().updateCard(id: id, front: front, back: back);
      Get.back();
      Get.snackbar(MyStrings.flashcardUpdated, '', snackPosition: SnackPosition.BOTTOM);
    }).catchError((e) => print(e));
  }

  Future<void> setDoc({required String collection, required dynamic doc, String? completeMention}) async {
    final ref = firestore.collection(collection).doc(doc.id);
    await ref.set(doc.toJson()).then((value) {
      completeMention != null ? Get.snackbar(completeMention, '') : null;
      print('setDoc is completed');
    }).catchError((e) => Get.snackbar(MyStrings.setError, e));
  }

  Future<dynamic> getDoc({required String collection, required String docId}) async {
    final ref = firestore.collection(collection).doc(docId);
    return await ref.get().then((value) => print('$collection/$docId is loaded'));
  }

  DocumentSnapshot? lastDoc;

  Future<List<dynamic>> getDocs(
      {required String collection,
      dynamic field,
      dynamic equalTo,
      required String orderBy,
      int? limit,
      bool isContinue = false,
      bool descending = true}) async {
    List<dynamic> documents = [];

    final ref = firestore.collection(collection);
    Query queryRef;

    if (limit == null) {
      if (field != null) {
        queryRef = ref.where(field, isEqualTo: equalTo).orderBy(orderBy, descending: descending);
      } else {
        queryRef = ref.orderBy(orderBy, descending: descending);
      }
    } else {
      if (field != null) {
        queryRef = ref.where(field, isEqualTo: equalTo).orderBy(orderBy, descending: descending).limit(limit);
        //queryRef.count()
      } else {
        queryRef = ref.orderBy(orderBy, descending: descending).limit(limit);
      }
      if (isContinue) {
        queryRef = queryRef.startAfterDocument(lastDoc!);
      }
    }

    await queryRef.get().then((QuerySnapshot snapshot) {
      print('quiring');
      for (QueryDocumentSnapshot documentSnapshot in snapshot.docs) {
        documents.add(documentSnapshot.data() as Map<String, dynamic>);
      }
      if (limit != null) {
        if (documents.isNotEmpty) {
          lastDoc = snapshot.docs.last;
        } else {
          return;
        }
      }
    }, onError: (e) => print('ERROR : $e'));
    return documents;
  }

  Future<List<dynamic>> getDocsWithQuery({required Query query}) async {
    List<dynamic> documents = [];

    await query.get().then((QuerySnapshot snapshot) {
      print('quiring');
      for (QueryDocumentSnapshot documentSnapshot in snapshot.docs) {
        documents.add(documentSnapshot.data() as Map<String, dynamic>);
      }
    }, onError: (e) => print('ERROR : $e'));
    return documents;
  }

  Future<void> deleteDoc({required String collection, required String docId}) async {
    DocumentReference ref = firestore.collection(collection).doc(docId);
    return await ref.delete().then((value) {
      print('Document is Deleted');
    }).catchError((e) => print(e));
  }

  Future<void> deleteDocs({required String collection, required List<String> ids}) async {
    final batch = firestore.batch();
    for (String docId in ids) {
      final ref = firestore.collection(collection).doc(docId);
      batch.delete(ref);
    }
    await batch.commit().then((value) => print('Documents are delete')).catchError((e) => print('ERROR: $e'));
  }

// Future<List<dynamic>> getListFieldFromDb(
//     {required String collection, required String field, required String arrayContains}) async {
//   List<dynamic> documents = [];
//   final ref = firestore.collection(collection);
//   final queryRef;
//   queryRef = ref.where(field, arrayContains: arrayContains);
//   await queryRef.get().then((QuerySnapshot snapshot) {
//     print('quering');
//     for (QueryDocumentSnapshot documentSnapshot in snapshot.docs) {
//       documents.add(documentSnapshot.data() as Map<String, dynamic>);
//     }
//   }, onError: (e) => print('ERROR : $e'));
//   return documents;
// }
//
// Future<List<dynamic>> getDocsFromList(
//     {required String collection, required String field, required List<dynamic> list}) async {
//   List<dynamic> titles = [];
//   final ref = firestore.collection(collection).where(field, whereIn: list);
//   await ref.get().then((QuerySnapshot snapshot) {
//     print('Get docs from list');
//     for (QueryDocumentSnapshot documentSnapshot in snapshot.docs) {
//       titles.add(documentSnapshot.data() as Map<String, dynamic>);
//     }
//   });
//   return titles;
// }
//
// Future<void> setDoc({required String collection, required dynamic doc}) async {
//   DocumentReference ref = firestore.collection(collection).doc(doc.id);
//   return await ref.set(doc.toJson()).then((value) {
//     print('Document is Saved');
//     Get.snackbar('Document is saved', 'id: ${doc.id}', snackPosition: SnackPosition.BOTTOM);
//   }).catchError((e) => print(e));
// }
//
//
// Future<void> switchOrderTransaction(
//     {required String collection, required String docId1, required String docId2}) async {
//   await firestore.runTransaction((transaction) async {
//     final ref1 = firestore.collection(collection).doc(docId1);
//     final ref2 = firestore.collection(collection).doc(docId2);
//     final doc1 = await transaction.get(ref1);
//     final doc2 = await transaction.get(ref2);
//     final doc1Index = doc1.get('orderId');
//     final doc2Index = doc2.get('orderId');
//     print('Transaction updating');
//     transaction.update(ref1, {'orderId': doc2Index});
//     transaction.update(ref2, {'orderId': doc1Index});
//   }).then((value) {
//     print('Transaction completed');
//     Get.snackbar('Transaction completed', '',
//         snackPosition: SnackPosition.BOTTOM);
//   }).onError((e, stackTrace) {
//     Get.snackbar('에러', e.toString(), snackPosition: SnackPosition.BOTTOM);
//   });
// }
//
// Future<void> addValueTransaction(
//     {required String collection,
//       required String docId,
//       required String field,
//       required dynamic addValue}) async {
//   firestore.runTransaction((transaction) async {
//     final ref = firestore.collection(collection).doc(docId);
//     final doc = await transaction.get(ref);
//     final newValue = doc.get(field);
//     newValue.add(addValue);
//     print('Transaction updating');
//     transaction.update(ref, {field: newValue});
//   }).then((_) {
//     print('Transaction completed');
//     Get.snackbar('레슨이 추가되었습니다.', addValue, snackPosition: SnackPosition.BOTTOM);
//   }).onError((e, stackTrace) {
//     Get.snackbar('에러', e.toString(), snackPosition: SnackPosition.BOTTOM);
//   });
// }
}
