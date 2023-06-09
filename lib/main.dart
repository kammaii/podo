import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/screens/login/login.dart';
import 'package:podo/screens/main_frame.dart';
import 'package:podo/screens/profile/user_info.dart' as user;
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Get any initial links : When the app is just opened by clicking the deepLink.
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

  // auth emulator init
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp(MyApp(initialLink: initialLink));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key, this.initialLink}) : super(key: key);

  PendingDynamicLinkData? initialLink;
  User? currentUser;
  bool isVerified = false;

  void runDeepLink(BuildContext context, PendingDynamicLinkData dynamicLinkData) async {
    FirebaseAuth.instance.currentUser!.reload();
    currentUser = FirebaseAuth.instance.currentUser;
    print(
        'dynamic link listening: verified? : ${FirebaseAuth.instance.currentUser!.emailVerified}, DynamicLink: $dynamicLinkData');
    Uri uri = Uri.parse(dynamicLinkData.link.toString());
    String mode = uri.queryParameters['mode']!;

    if (mode == 'verifyEmail' && currentUser!.emailVerified) {
      await user.User().initUserWithEmail(context);
      Get.snackbar(MyStrings.welcome, '');
      Get.to(const MainFrame());
    } else {
      Get.to(Login());
    }
  }

  @override
  Widget build(BuildContext context) {
    currentUser = FirebaseAuth.instance.currentUser;
    currentUser != null && currentUser!.emailVerified ? isVerified = true : isVerified = false;

    Widget homeWidget;
    if (currentUser != null && isVerified) {
      homeWidget = const MainFrame();
      user.User().getUser();
    } else {
      //homeWidget = Login();
      homeWidget = const MainFrame();
    }


    if (initialLink != null) {
      // Dynamic listener : When the app is just opened.
      runDeepLink(context, initialLink!);
      print('InitialLink: $initialLink');
    }

    // DynamicLink listener : When the app is already running.
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      runDeepLink(context, dynamicLinkData);
    }).onError((error) {
      print('ERROR on DynamicLinkListener: $error');
    });


    return GetMaterialApp(
      title: 'Podo Korean app',
      theme: ThemeData(primaryColor: MyColors.purple),
      home: homeWidget,
    );
  }
}
