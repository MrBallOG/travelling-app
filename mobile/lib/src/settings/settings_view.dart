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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Select theme mode",
                  textScaleFactor: 1,
                ),
                Consumer<SettingsController>(
                  builder: (context, controller, child) =>
                      DropdownButton<ThemeMode>(
                    value: controller.themeMode,
                    onChanged: controller.updateThemeMode,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60.0),
                    ),
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
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
                    } catch (_) {
                      const snackBar = SnackBar(
                        content: Text("Failed to sign out"),
                        duration: Duration(seconds: 3),
                      );
                      messenger.showSnackBar(snackBar);
                    }
                  },
                  child: const Text("Sign out"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
