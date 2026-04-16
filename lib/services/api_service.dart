import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://localhost:3000';

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getProductsByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products?category=$category'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products?search=${Uri.encodeComponent(query)}'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getCartItems(String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cart/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addToCart(
      String userId, Map<String, dynamic> product, int quantity) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/cart/$userId/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'productId': product['_id'],
        'name': product['name'],
        'price': product['price'],
        'image_url': product['image_url'] ?? '',
        'quantity': quantity,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateCartItem(
      String userId, String productId, int quantity) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/cart/$userId/item/$productId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'quantity': quantity}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> removeCartItem(
      String userId, String productId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/cart/$userId/item/$productId'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> clearCart(String userId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/cart/$userId/clear'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createOrder({
    required String userId,
    required List<dynamic> items,
    required double total,
    String address = '',
    String paymentMethod = 'efectivo',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'items': items,
        'total': total,
        'address': address,
        'paymentMethod': paymentMethod,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getOrders(String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/orders/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }
}
