import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/screens/login/login.dart';
import 'package:podo/screens/main_frame.dart';
import 'package:podo/values/my_colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();

  // Get any initial links : When the app is just opened by clicking the deepLink.
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

  // auth emulator init
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp(MyApp(initialLink: initialLink));
}

class MyApp extends StatelessWidget {
  PendingDynamicLinkData? initialLink;

  MyApp({Key? key, this.initialLink}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (initialLink != null) {
      // Dynamic link를 통해 앱을 신규설치하거나 업데이트 했을 때 작동 -> 해당 딥링크에 맞는 화면 보여줌
      final Uri deepLink = initialLink!.link;
      print(deepLink);
    }

    // DynamicLink listener : When the app is already running
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      print('dynamic link listening');
      print('verified? : ${FirebaseAuth.instance.currentUser!.emailVerified}');
    }).onError((error) {
      // Handle errors
    });

    return GetMaterialApp(
      title: 'Podo Korean app',
      theme: ThemeData(primaryColor: MyColors.purple),
      home: const MainFrame(),
    );
  }
}
