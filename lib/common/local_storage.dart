import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage.init();
  late final SharedPreferences prefs;

  factory LocalStorage() {
    return _instance;
  }

  LocalStorage.init() {
    init();
  }

  void init() async{
    prefs = await SharedPreferences.getInstance();
    print('LocalStorage 초기화');
  }

}