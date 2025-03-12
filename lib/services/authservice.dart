import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "https://localhost:5001";

  Future<Map<String, dynamic>> login(
      String phoneNumber, String password) async {
    final url = Uri.parse('$baseUrl/register/authenticate');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userName': phoneNumber, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Invalid credentials'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> signUp(
      String name, String mobileNumber, String password) async {
    final url = Uri.parse('$baseUrl/register/individual');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'mobileNumber': mobileNumber,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Registration failed'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
