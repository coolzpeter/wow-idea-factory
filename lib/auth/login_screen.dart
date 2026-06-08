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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Replace your existing Center widget with this:
      body: Center(
        // ConstrainedBox limits the width on desktop screens
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment
                  .stretch, // Makes buttons/fields stretch to fill the 400px
              children: [
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 40),

                TextField(
                  controller: _usernameController,
                  textInputAction: TextInputAction
                      .next, // Pressing "Tab" or "Enter" moves to the next field
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border:
                        OutlineInputBorder(), // Adds a clean box around the input
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) =>
                      _signIn(), // THIS triggers login when you press Enter!
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(onPressed: _signIn, child: const Text('Login')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
