import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class Credentials {
  final _auth = FirebaseAuth.instance;
  Future<UserCredential?> getGoogleCredential() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential =  await _auth.signInWithCredential(credential);
      if(userCredential.additionalUserInfo!.isNewUser) {
        String userId = auth.FirebaseAuth.instance.currentUser!.uid;
        await FirebaseAnalytics.instance.logSignUp(signUpMethod: 'google', parameters: {'userId': userId});
      }
      return userCredential;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> getAppleCredential() async {
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
        clientId: 'net.awesomekorean.newpodo',
        redirectUri: Uri.parse('https://newpodo.page.link/?mode=verifyEmail'),
      ),
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );
    UserCredential userCredential = await _auth.signInWithCredential(oauthCredential);
    if(userCredential.additionalUserInfo!.isNewUser) {
      String userId = auth.FirebaseAuth.instance.currentUser!.uid;
      await FirebaseAnalytics.instance.logSignUp(signUpMethod: 'apple', parameters: {'userId': userId});
    }
    return userCredential;
  }
}