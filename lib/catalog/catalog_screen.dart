import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';
import '../services/supabase_service.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

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
    // Removed the underscore. Local variables do not use private prefixes.
    final dbService = SupabaseService(); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('WoW Idea Factory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbService.fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data;
          if (products == null || products.isEmpty) {
            return const Center(child: Text('No products found in the database.'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: const Icon(Icons.inventory_2),
                title: Text(product['product_name'] ?? 'Unknown Name'),
                subtitle: Text('Code: ${product['product_code']} | Type: ${product['product_type']}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Replaced print() with debugPrint() for production safety
                  debugPrint("Clicked on ${product['product_name']}");
                },
              );
            },
          );
        },
      ),
    );
  }
}