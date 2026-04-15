import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.tudominio.com';

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
}
