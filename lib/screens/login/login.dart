import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:podo/screens/my_page/user.dart' as user;


// apple OAuth callback : https://podo-49335.firebaseapp.com/__/auth/handler

class Login extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  late TargetPlatform os;


  Future<void> _sendEmailVerificationLink(String email) async {
    await _auth.currentUser?.sendEmailVerification(ActionCodeSettings(
      url: 'https://newpodo.page.link/?mode=verifyEmail',
      androidPackageName: 'net.awesomekorean.newpodo',
      androidInstallApp: true,
      androidMinimumVersion: '12',
      iOSBundleId: 'net.awesomekorean.newpodo',
      handleCodeInApp: false,
      dynamicLinkDomain: 'newpodo.page.link',
    ));
    print('EMAIL SNT');
  }

  @override
  Widget build(BuildContext context) {
    os = Theme.of(context).platform;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Center(
        child: FlutterLogin(
          logo: 'assets/images/logo.png',
          title: MyStrings.welcome,
          theme: LoginTheme(
              primaryColor: MyColors.purple,
              pageColorLight: MyColors.green,
              accentColor: MyColors.purple,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          loginProviders: <LoginProvider>[
            LoginProvider(
              icon: FontAwesomeIcons.google,
              callback: () async {
                try {
                  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
                  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
                  final credential = GoogleAuthProvider.credential(
                    accessToken: googleAuth?.accessToken,
                    idToken: googleAuth?.idToken,
                  );
                  await _auth.signInWithCredential(credential);
                  return null;
                } catch (e) {
                  print('Error: $e');
                  return 'Error: $e';
                }
              },
            ),
            LoginProvider(
              icon: FontAwesomeIcons.apple,
              callback: () async {
                final appleProvider = AppleAuthProvider();
                if (kIsWeb) {
                  await FirebaseAuth.instance.signInWithPopup(appleProvider);
                } else {
                  await FirebaseAuth.instance.signInWithProvider(appleProvider);
                }
              },
            )
          ],
          onSignup: (data) async {
            try {
              String email = data.name.toString();
              await _auth.createUserWithEmailAndPassword(email: email, password: data.password.toString());
              print('USER CREATED');

              final user = _auth.currentUser;
              if (user != null && !user.emailVerified) {
                print('USER: $user');
                await _sendEmailVerificationLink(user.email!);
                Get.dialog(Stack(
                  children: const [
                    Offstage(
                      offstage: false,
                      child: Opacity(opacity: 0.5, child: ModalBarrier(dismissible: false, color: Colors.black)),
                    ),
                    AlertDialog(
                      title: Text(MyStrings.verificationEmailTitle),
                      content: Text(MyStrings.verificationEmailContent),
                    ),
                  ],
                ));
                return null;
              }
            } on FirebaseAuthException catch (e) {
              if (e.code == 'weak-password') {
                print('The password provided is too weak.');
              } else if (e.code == 'email-already-in-use') {
                print('The account already exists for that email.');
              } else {
                print('ERRORRR: $e');
              }
              return e.toString();
            }
            return null;
          },
          onLogin: (data) async {
            try {
              await _auth.signInWithEmailAndPassword(email: data.name, password: data.password);
              return null;
            } catch (e) {
              return e.toString();
            }
          },
          onRecoverPassword: (name) async {
            try {
              await _auth.sendPasswordResetEmail(email: name);
              return null;
            } catch (e) {
              return e.toString();
            }
          },
          onSubmitAnimationCompleted: () {
            print('onSubmitAnimationCompleted');
            //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainFrame()));
          },
        ),
      ),
    );
  }
}
