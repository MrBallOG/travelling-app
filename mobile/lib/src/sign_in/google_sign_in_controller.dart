import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSingInController with ChangeNotifier {
  final GoogleSignIn _googleSingIn = GoogleSignIn();

  Future<void> loginUser() async {
    final googleUser = await _googleSingIn.signIn();

    if (googleUser == null) {
      throw ArgumentError();
      // return;
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    notifyListeners();
  }
}
