import 'dart:convert';
import 'dart:math';
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
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';


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

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
        clientId:
        'net.awesomekorean.newpodo',

        redirectUri: Uri.parse('https://newpodo.page.link/?mode=verifyEmail'),
      ),
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
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
                signInWithApple();
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
