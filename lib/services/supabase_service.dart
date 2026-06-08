import 'package:flutter/foundation.dart';
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
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    // This is the Flutter equivalent of "SELECT * FROM products"
    final response = await _client.from('products').select();

    // We convert the raw data into a format Flutter can easily read
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchDesignsForProduct(
    String productId,
  ) async {
    // This equals: SELECT * FROM designs WHERE product_id = 'the-id-passed-in'
    final response = await _client
        .from('designs')
        .select()
        .eq('product_id', productId);

    return List<Map<String, dynamic>>.from(response);
  }

  // Fetch the minimum order quantity from price_tiers
  Future<int> fetchMinQuantity(String productId) async {
    try {
      final response = await _client
          .from('price_tiers')
          .select('min_qty')
          .eq('product_id', productId)
          .order('min_qty', ascending: true)
          .limit(1)
          .single();

      return response['min_qty'] as int;
    } catch (e) {
      debugPrint('Error fetching min quantity: $e');
      // If no price tier is found, fallback to 100
      return 100;
    }
  }

  // Submit a Quote Request
  Future<void> requestQuote(String designId, int quantity) async {
    final userId = _client.auth.currentUser!.id;

    // Create the master order record
    final orderResponse = await _client
        .from('orders')
        .insert({'customer_id': userId, 'status': 'pending_quote'})
        .select()
        .single();

    final orderId = orderResponse['id'];

    // Add the selected design to order_items
    await _client.from('order_items').insert({
      'order_id': orderId,
      'design_id': designId,
      'quantity': quantity,
    });
  }
}
