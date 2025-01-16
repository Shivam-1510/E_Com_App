// https://localhost:7157
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthService {
  static const String baseUrl = "https://localhost:7157";
  static final _storage = FlutterSecureStorage(); // Secure storage instance

  Future<Map<String, dynamic>> login(
      String phoneNumber, String password) async {
    final url = Uri.parse('$baseUrl/register/authenticate');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"userName": phoneNumber, "password": password}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Store the token securely
        await _storage.write(key: 'authToken', value: responseBody['token']);

        return responseBody;
      } else {
        return {'error': 'Invalid credentials'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> signUp(
      String name, String phoneNumber, String password) async {
    final url = Uri.parse('$baseUrl/register/individual');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'name': name, 'moblieNumber': phoneNumber, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Store the token securely after signup
        await _storage.write(key: 'authToken', value: responseBody['token']);

        return responseBody;
      } else {
        return {'error': 'Registration failed'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Method to retrieve the token
  Future<String?> getToken() async {
    return await _storage.read(key: 'authToken');
  }

  // Method to delete the token during logout
  Future<void> logout() async {
    await _storage.delete(key: 'authToken');
  }

  // Method to check if the user is logged in
  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null;
  }
}
