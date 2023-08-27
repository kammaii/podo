import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class CloudStorage {
  static final CloudStorage _instance = CloudStorage.init();

  factory CloudStorage() {
    return _instance;
  }

  final storage = FirebaseStorage.instance;

  CloudStorage.init() {
    print('CloudStorage 초기화');
  }

  Future<List<Map<String, String>>> downloadAudios({required String folderName, required String folderId}) async {
    List<Map<String, String>> audios = [];
    try {
      final result = await storage.ref().child("$folderName/$folderId").listAll();
      print('Downloading audios');
      for (var file in result.items) {
        RegExp regex = RegExp(r'^(.+)\.m4a$');
        if(regex.firstMatch(file.name) != null) {
          final fileName = regex.firstMatch(file.name)!.group(1);
          String url = await file.getDownloadURL();
          audios.add({fileName!: url});
        }
      }
    } catch (e) {
      print('ERROR: $e');
    }
    return audios;
  }

  Future<File?> downloadAudio({required String folderName, required String folderId, required String fileId}) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      File file = File('${tempDir.path}/$fileId');
      final TaskSnapshot snapshot = await storage.ref().child("$folderName/$folderId/$fileId.m4a").writeToFile(file);
      if(snapshot.state == TaskState.success) {
        print('Downloading succeed');
        return file;
      } else {
        print('Downloading failed');
        return null;
      }
    } catch (e) {
      print('ERROR: $e');
      return null;
    }
  }


  Future<String> getAudio({required List<String> audio}) async {
    final ref = storage.ref().child("${audio[0]}/${audio[1]}/${audio[2]}.m4a");
    String url = await ref.getDownloadURL();
    return url;
  }
}
