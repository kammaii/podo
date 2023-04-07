import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:podo/values/my_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

// apple OAuth callback : https://podo-49335.firebaseapp.com/__/auth/handler

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);


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

  Future<String?> _Login(LoginData data) {
    return Future.delayed(loginTime).then((_) {
      return 'Login Succeed';
    });
  }

  Future<String?> _Signup(SignupData data) async {
    try {
      final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data.name.toString(),
        password: data.password.toString(),
      );

      print('here');

      var acs = ActionCodeSettings(
        // URL you want to redirect back to. The domain (www.example.com) for this
        // URL must be whitelisted in the Firebase Console.
        //url: 'http://localhost/?email=${authResult.user!.email}',
        url: 'https://podoapp.page.link/verify',
        //dynamicLinkDomain: 'podoapp.page.link',
        androidPackageName: 'net.awesomekorean.podo',
        androidInstallApp: true,
        androidMinimumVersion: '12',
        iOSBundleId: 'net.awesomekorean.podo',
        handleCodeInApp: true,
      );

      //final user = FirebaseAuth.instance.currentUser;
      await authResult.user?.sendEmailVerification();
      print('email sent');

      final parameters = DynamicLinkParameters(
        uriPrefix: 'https://podoapp.page.link',
        link: Uri.parse('https://podoapp.page.link/email_verification?email=${authResult.user?.email}'),
        androidParameters: const AndroidParameters(
          packageName: 'net.awesomekorean.podo',
        ),
        iosParameters: const IOSParameters(
          bundleId: 'net.awesomekorean.podo',
        ),
      );

      final dynamicUrl = await FirebaseDynamicLinks.instance.buildShortLink(parameters);

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
    return Future.delayed(loginTime).then((_) {
      return 'Signup Succeed';
    });
  }

  Future<String?> _Recover(String data) {
    return Future.delayed(loginTime).then((_) {
      return 'Recover Succeed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlutterLogin(
        logo: 'assets/images/logo.png',
        title: 'Welcome to podo',
        theme: LoginTheme(
            primaryColor: MyColors.purple,
            pageColorLight: MyColors.green,
            accentColor: MyColors.purple,
            titleStyle: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
          return _Signup(signupData);
        },
        onLogin: (loginData) {
          String email = loginData.name;
          String password = loginData.password;
          print(email);
          print(password);
          print('verified? : ${FirebaseAuth.instance.currentUser!.emailVerified}');
          return _Login(loginData);
        },
        onRecoverPassword: (name) {
          print('recover password');
          return _Recover(name);
        },
        onSubmitAnimationCompleted: () {
          print('onSubmitAnimationCompleted');
          //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainFrame()));
        },
      ),
    );
  }
}
