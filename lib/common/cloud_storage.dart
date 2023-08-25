import 'package:firebase_storage/firebase_storage.dart';

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

  Future<String> getAudio({required List<String> audio}) async {
    final ref = storage.ref().child("${audio[0]}/${audio[1]}/${audio[2]}.mp3");
    String url = await ref.getDownloadURL();
    return url;
  }
}
