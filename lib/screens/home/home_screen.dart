// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inward_outward_management/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Welcome, ${user?.displayName ?? user?.email ?? 'User'}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await auth.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
