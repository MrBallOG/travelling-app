import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:mobile/src/profile/profile_view.dart';
import 'package:mobile/src/sign_in/google_sign_in_controller.dart';
import 'package:provider/provider.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  static const routeName = '/sign_in';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<GoogleSingInController>(
          builder: (context, controller, child) => SizedBox(
            width: 220,
            height: 60,
            child: SignInButton(
              Buttons.Google,
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final navigator = Navigator.of(context);
                  await controller.signInUser();
                  await navigator.popAndPushNamed(ProfileView.routeName);
                } on ArgumentError catch (_) {
                  const snackBar = SnackBar(
                    content: Text('Failed to sign in'),
                    duration: Duration(seconds: 3),
                  );
                  messenger.showSnackBar(snackBar);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
