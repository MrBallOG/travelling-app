import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile/src/settings/settings_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      restorationId: 'profile',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(user.photoURL!),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                user.displayName!,
                textScaleFactor: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
