import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'authservice.dart'; // Import AuthService for token management

class CustomHttpClient {
  final AuthService _authService = AuthService(); // Instance of AuthService
  static const String baseUrl = "https://localhost:7157"; // Your API base URL

  // Function to send a GET request with the token in the headers
  Future<http.Response> get(String endpoint) async {
    final token =
        await _authService.getToken(); // Retrieve token from AuthService
    // Ensure that headers are always a Map<String, String>
    final Map<String, String> headers = {};

    if (token != null && !JwtDecoder.isExpired(token)) {
      headers['Authorization'] =
          'Bearer $token'; // Add token in headers if available and not expired
    }

    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'), // Complete the URL with the endpoint
      headers: headers, // Pass headers as a Map<String, String>
    );

    return response;
  }

  // Function to send a POST request with the token in the headers
  Future<http.Response> post(String endpoint, dynamic body) async {
    final token =
        await _authService.getToken(); // Retrieve token from AuthService
    final headers = token != null && !JwtDecoder.isExpired(token)
        ? {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          } // Add token in headers
        : {
            'Content-Type': 'application/json'
          }; // If no token or expired, send request without Authorization header

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'), // Complete the URL with the endpoint
      headers: headers,
      body: jsonEncode(body), // Encode body to JSON format
    );

    return response;
  }
}
