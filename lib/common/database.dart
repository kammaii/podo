import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:flutter/material.dart';

class Database {
  static final Database _instance = Database.init();

  factory Database() {
    return _instance;
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Database.init() {
    print('Database 초기화');
  }

  Future<void> updateFlashcard({required FlashCard card}) async {
    final collection = 'Users/${User().id}/FlashCards';
    DocumentReference ref = firestore.collection(collection).doc(card.id);
    return await ref.update({'front': card.front, 'back': card.back, 'date': card.date}).then((value) {
      'Update succeed';
    }).catchError((e) => print(e));
  }

  Future<void> updateDoc(
      {required String collection, required String docId, required String key, required dynamic value}) async {
    final ref = firestore.collection(collection).doc(docId);
    ref.update({key: value}).then((val) => print('Update succeed: $key $value'),
        onError: (e) => print('Update error: $e'));
  }

  Future<void> setDoc({required String collection, required dynamic doc, Function(dynamic)? thenFn}) async {
    final ref = firestore.collection(collection).doc(doc.id);
    if (thenFn != null) {
      await ref.set(doc.toJson()).then(thenFn).catchError((e) => Get.snackbar(tr('setError'), e));
    } else {
      await ref
          .set(doc.toJson())
          .then((value) => print('setDoc completed'))
          .catchError((e) => Get.snackbar(tr('setError'), e));
    }
  }

  Future<dynamic> getDoc({required String collection, required String docId}) async {
    dynamic document;
    final ref = firestore.collection(collection).doc(docId);
    try {
      await ref.get().then((DocumentSnapshot snapshot) {
        print('$collection/$docId is loaded');
        document = snapshot;
      });
    } catch(e) {
      Get.defaultDialog(content: Text(e.toString()));
    }
    return document;
  }

  Future<List<dynamic>> getDocs({required Query query}) async {
    List<dynamic> documents = [];

    await query.get().then((QuerySnapshot snapshot) {
      print('quiring');
      for (QueryDocumentSnapshot documentSnapshot in snapshot.docs) {
        documents.add(documentSnapshot);
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
}
