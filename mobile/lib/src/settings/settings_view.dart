import 'package:flutter/material.dart';
import 'package:mobile/src/sign_in/google_sign_in_controller.dart';
import 'package:provider/provider.dart';

import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                child: Consumer<SettingsController>(
                  builder: (context, controller, child) =>
                      DropdownButton<ThemeMode>(
                    value: controller.themeMode,
                    onChanged: controller.updateThemeMode,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark Theme'),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                child: ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    final singInController =
                        Provider.of<GoogleSingInController>(context,
                            listen: false);
                    await singInController.signOut();
                    const snackBar = SnackBar(
                      content: Text("You've been signed out"),
                      duration: Duration(seconds: 3),
                    );
                    messenger.showSnackBar(snackBar);
                    await navigator.pushNamedAndRemoveUntil(
                        "/sign_in", (r) => false);
                  },
                  child: const Text("Sign Out"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
