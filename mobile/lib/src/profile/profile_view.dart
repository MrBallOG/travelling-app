import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(user!.displayName!),
      ),
    );
  }
}
