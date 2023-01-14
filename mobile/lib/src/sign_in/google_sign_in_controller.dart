import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSingInController {
  final GoogleSignIn _googleSingIn = GoogleSignIn();

  Future<void> signInUser() async {
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

    // notifyListeners();
  }

  Future<void> signOutUser() async {
    await _googleSingIn.disconnect();
    await FirebaseAuth.instance.signOut();
  }
}
