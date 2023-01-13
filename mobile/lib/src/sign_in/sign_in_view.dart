import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:mobile/src/sign_in/google_sign_in_controller.dart';
import 'package:provider/provider.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<GoogleSingInController>(
          builder: (context, controller, child) => SizedBox(
            // TextButton(
            //   onPressed: () async {
            //     final messenger = ScaffoldMessenger.of(context);
            //     try {
            //       await controller.loginUser();
            //     } on ArgumentError catch (_) {
            //       const snackBar = SnackBar(
            //         content: Text('Nie udało się zalogować'),
            //       );
            //       messenger.showSnackBar(snackBar);
            //     }
            //   },
            //   child: const Text("Zaloguj się przez Google"),
            // ),
            width: 220,
            height: 60,
            child: SignInButton(
              Buttons.Google,
              text: "Zaloguj się przez Google",
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await controller.loginUser();
                } on ArgumentError catch (_) {
                  const snackBar = SnackBar(
                    content: Text('Nie udało się zalogować'),
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
