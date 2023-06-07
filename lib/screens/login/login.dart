import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:podo/values/my_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:podo/values/my_strings.dart';

// apple OAuth callback : https://podo-49335.firebaseapp.com/__/auth/handler

class Login extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  // Future<String?> _loginUser(LoginData data) {
  //   return Future.delayed(loginTime).then((_) {
  //     if (!mockUsers.containsKey(data.name)) {
  //       return 'User not exists';
  //     }
  //     if (mockUsers[data.name] != data.password) {
  //       return 'Password does not match';
  //     }
  //     return null;
  //   });
  // }

  Future<String?> _logIn(LoginData data) {
    return Future.delayed(loginTime).then((_) {
      return 'Login Succeed';
    });
  }
  Future<void> _sendEmailVerificationLink(String email) async {
    await _auth.currentUser?.sendEmailVerification(
      ActionCodeSettings(
        url: 'https://newpodo.page.link/?mode=verifyEmail',
        androidPackageName: 'net.awesomekorean.newpodo',
        androidInstallApp: true,
        androidMinimumVersion: '12',
        iOSBundleId: 'net.awesomekorean.newpodo',
        handleCodeInApp: false,
        dynamicLinkDomain: 'newpodo.page.link',
      )
    );
    print('EMAIL SENT');
  }

  Future<String?> _signUpWithEmail(SignupData data) async {
    try {
      String email = data.name.toString();
      await _auth.createUserWithEmailAndPassword(email: email, password: data.password.toString());
      print('USER CREATED');

      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        print('USER: $user');
        await _sendEmailVerificationLink(user.email!);
        Get.dialog(const AlertDialog(
          title: Text(MyStrings.verificationEmailTitle),
          content: Text(MyStrings.verificationEmailContent),
        ));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      } else {
        print('ERRORRR: $e');
      }
    } catch (e) {
      print(e);
    }
    return 'Signup Succeed';
  }

  Future<String?> _recover(String data) {
    return Future.delayed(loginTime).then((_) {
      return 'Recover Succeed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
              print('start google sign in');
              return null;
            },
          ),
          LoginProvider(
            icon: FontAwesomeIcons.apple,
            callback: () async {
              print('start apple sign in');
              return null;
            },
          )
        ],
        onSignup: (signupData) {
          print('signupData : $signupData');
          return _signUpWithEmail(signupData);
        },
        onLogin: (loginData) {
          String email = loginData.name;
          String password = loginData.password;
          print(email);
          print(password);
          print('verified? : ${FirebaseAuth.instance.currentUser!.emailVerified}');
          return _logIn(loginData);
        },
        onRecoverPassword: (name) {
          print('recover password');
          return _recover(name);
        },
        onSubmitAnimationCompleted: () {
          print('onSubmitAnimationCompleted');
          //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainFrame()));
        },
      ),
    );
  }
}
