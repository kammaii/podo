import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:podo/screens/login/credentials.dart';
import 'package:podo/values/my_colors.dart';

// apple OAuth callback : https://podo-49335.firebaseapp.com/__/auth/handler

class Login extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  late TargetPlatform os;

  Future<void> _sendEmailVerificationLink(String email) async {
    await _auth.currentUser?.sendEmailVerification(ActionCodeSettings(
      url: 'https://link.podokorean.com/korean?mode=verifyEmail',
      androidPackageName: 'net.awesomekorean.newpodo',
      iOSBundleId: 'net.awesomekorean.newpodo',
      handleCodeInApp: true,
    ));
    print('EMAIL SNT');
  }

  @override
  Widget build(BuildContext context) {
    os = Theme.of(context).platform;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        await Get.dialog(AlertDialog(
          title: Text(tr('exitApp')),
          actions: [
            TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text(tr('yes'), style: TextStyle(color: MyColors.navy))),
            TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text(tr('no'), style: TextStyle(color: MyColors.purple))),
          ],
        ));
      },
      child: Center(
        child: FlutterLogin(
          logo: 'assets/images/logo.png',
          title: tr('welcome'),
          theme: LoginTheme(
            primaryColor: MyColors.purple,
            pageColorLight: MyColors.green,
            accentColor: MyColors.purple,
            titleStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          loginProviders: <LoginProvider>[
            LoginProvider(
              icon: FontAwesomeIcons.google,
              callback: () async {
                await Credentials().getGoogleCredential();
                return null;
              },
            ),
            LoginProvider(
              icon: FontAwesomeIcons.apple,
              callback: () async {
                await Credentials().getAppleCredential();
                return null;
              },
            )
          ],
          onSignup: (data) async {
            try {
              String email = data.name.toString();
              UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: data.password.toString());
              print('USER CREATED');

              final user = _auth.currentUser;
              if (user != null && !user.emailVerified) {
                print('USER: $user');
                if(userCredential.additionalUserInfo!.isNewUser) {
                  await FirebaseAnalytics.instance.logSignUp(signUpMethod: 'email', parameters: {'userId': user.uid});
                }
                await _sendEmailVerificationLink(user.email!);
                Get.dialog(Stack(
                  children: [
                    const Offstage(
                      offstage: false,
                      child: Opacity(opacity: 0.5, child: ModalBarrier(dismissible: false, color: Colors.black)),
                    ),
                    AlertDialog(
                      title: Text(tr('verificationEmailTitle')),
                      content: Text(tr('verificationEmailContent')),
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
          },
        ),
      ),
    );
  }
}
