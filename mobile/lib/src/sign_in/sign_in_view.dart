import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:mobile/src/profile/profile_view.dart';
import 'package:mobile/src/sign_in/google_sign_in_controller.dart';
import 'package:provider/provider.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  static const routeName = '/sign_in';

  @override
  State<StatefulWidget> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  bool isLoading = false;

  void setLoading() {
    setState(() {
      isLoading = true;
    });
  }

  void unSetLoading() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Logo"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isLoading)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: 220,
                    height: 60,
                    child: SignInButton(
                      Buttons.Google,
                      onPressed: () async {
                        setLoading();
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final navigator = Navigator.of(context);
                          final singInController =
                              Provider.of<GoogleSingInController>(context,
                                  listen: false);
                          await singInController.signIn();
                          await navigator
                              .popAndPushNamed(ProfileView.routeName);
                        } catch (_) {
                          unSetLoading();
                          const snackBar = SnackBar(
                            content: Text("Failed to sign in"),
                            duration: Duration(seconds: 3),
                          );
                          messenger.showSnackBar(snackBar);
                        }
                      },
                    ),
                  ),
                ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: CircularProgressIndicator(),
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }
}
