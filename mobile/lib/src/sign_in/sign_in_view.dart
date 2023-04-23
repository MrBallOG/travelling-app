import 'package:flutter/material.dart';
import 'package:mobile/src/main_view/main_view.dart' show MainView;
import 'package:mobile/src/sign_in/google_sign_in_controller.dart';
import 'package:mobile/src/widget/snackbars.dart';
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
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.forest,
                      color: Colors.green,
                      size: 80,
                    ),
                    Icon(
                      Icons.phone_android,
                      size: 60,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Travelling app", textScaleFactor: 2.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isLoading)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: 216,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60.0),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Row(
                          children: const [
                            Image(
                              image: AssetImage('assets/logos/google_light.png',
                                  package: "flutter_signin_button"),
                            ),
                            Text(
                              "Sign in with Google",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          setLoading();
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            final navigator = Navigator.of(context);
                            final singInController =
                                Provider.of<GoogleSingInController>(context,
                                    listen: false);
                            await singInController.signIn();
                            navigator
                                .restorablePopAndPushNamed(MainView.routeName);
                          } catch (_) {
                            unSetLoading();
                            messenger.showSnackBar(
                                snackBarFailure("Failed to sign in"));
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
          ),
        ],
      ),
    );
  }
}
