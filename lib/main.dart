import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/screens/login/login.dart';
import 'package:podo/screens/main_frame.dart';
import 'package:podo/screens/profile/user_info.dart' as user_info;
import 'package:podo/values/my_colors.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // auth emulator init
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  User? currentUser;

  void runDeepLink(Uri deepLink) async {
    await FirebaseAuth.instance.currentUser!.reload();
    currentUser = FirebaseAuth.instance.currentUser;
    Uri uri = Uri.parse(deepLink.toString());
    String mode = uri.queryParameters['mode']!;

    if (mode == 'verifyEmail' && currentUser!.emailVerified) {
      await user_info.User().initNewUserOnDB();
      Get.to(const MainFrame());
    }
  }

  void initDynamicLinks() async {
    // DynamicLink listener : When the app is already running.
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final deepLink = dynamicLinkData.link;
      if (deepLink != null) {
        runDeepLink(deepLink);
      }
    }).onError((error) {
      print('ERROR on DynamicLinkListener: $error');
    });

    // Get any initial links : When the app is just opened by clicking the deepLink.
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    final deepLink = data?.link;
    if (deepLink != null) {
      runDeepLink(deepLink);
    }
  }

  @override
  Widget build(BuildContext context) {

    initDynamicLinks();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if(user != null) {
        if(user.emailVerified) {
          print('AUTH STATE CHANGES: Email Verified');
          user_info.User();
          Get.to(const MainFrame());
        } else {
          print('AUTH STATE CHANGES: Email not Verified');
          Get.to(Login());
        }
      } else {
        print('AUTH STATE CHANGES: User is null');
        Get.to(Login());
      }
    });

    return GetMaterialApp(
      title: 'Podo Korean app',
      theme: ThemeData(primaryColor: MyColors.purple),
      home: const Center(child: CircularProgressIndicator()),
    );
  }
}
