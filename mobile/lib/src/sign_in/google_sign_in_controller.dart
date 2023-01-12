import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSingInProvider with ChangeNotifier {
  final GoogleSignIn _googleSingIn = GoogleSignIn();

  late GoogleSignInAccount _user;

  GoogleSignInAccount get user => _user;

  Future<void> loginUser() async {
    final user = await _googleSingIn.signInSilently();

    if (user == null) return;
    _user = user;

    final googleAuth = await _user.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    notifyListeners();
  }
}
