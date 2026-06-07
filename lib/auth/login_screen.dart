import 'package:flutter/material.dart';
import '../services/supabase_service.dart'; // Import the new service
import '../catalog/catalog_screen.dart'; // Import the CatalogScreen for navigation

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = SupabaseService(); // Initialize the service

  Future<void> _signIn() async {
    try {
      await _authService.signIn(
        _usernameController.text,
        _passwordController.text,
      );
      // If no error is thrown, navigation will happen here
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CatalogScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            ElevatedButton(onPressed: _signIn, child: const Text('Login')),
          ],
        ),
      ),
    );
  }
}