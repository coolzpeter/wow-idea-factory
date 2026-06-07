import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Sign In Function
  Future<AuthResponse> signIn(String username, String password) async {
    // We append a domain to treat usernames as emails as discussed
    final email = '$username@wowfactory.com'; 
    
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  // You can add more methods here later, like fetchProducts() or placeOrder()
}