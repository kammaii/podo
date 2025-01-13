import 'package:firebase_remote_config/firebase_remote_config.dart';

class MyRemoteConfig {
  static final MyRemoteConfig _instance = MyRemoteConfig.init();
  late final _remoteConfig;

  static const IS_FREE_TRIAL_ENABLED = 'isFreeTrialEnabled';

  factory MyRemoteConfig() {
    return _instance;
  }

  MyRemoteConfig.init() {
    print('RemoteConfig 초기화');
    _remoteConfig = FirebaseRemoteConfig.instance;
    _remoteConfig.onConfigUpdated.listen((event) async {
      print('CONFIG LISTEN: $event');
      await _remoteConfig.activate();
    });
    setDefaults();
  }

  setDefaults() async {
    print('RemoteConfig 기본값 설정');
    await _remoteConfig.setDefaults(const {
      IS_FREE_TRIAL_ENABLED: true
    });
  }

  bool getConfigBool(String key) {
    return _remoteConfig.getBool(key);
  }
}