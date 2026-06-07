import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  // A quick sign-out function for testing
  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WoW idea factory Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          )
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to the Catalog!\nYour products will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}