import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Library for decoding JWT tokens.

class UserRoleService {
  final String baseUrl = "https://localhost:5001";

  // Function to get the token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Function to decode the JWT token and extract claims
  Map<String, dynamic>? decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }

  // Function to fetch user role level based on token and API response
  Future<Map<String, dynamic>?> getUserDetails() async {
    final token = await getToken();

    if (token == null) {
      return null; // Unauthorized access
    }

    // Decode JWT token
    final decodedToken = decodeToken(token);
    if (decodedToken == null || !decodedToken.containsKey('role')) {
      return null;
    }

    final String tokenRole = decodedToken['role'];

    // Make API call to fetch user details
    final url = Uri.parse('$baseUrl/user/userbyclaim');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);

        if (userData.containsKey('userRoles') &&
            userData['userRoles'] is List<dynamic>) {
          final List<dynamic> userRoles = userData['userRoles'];

          // Find matching role
          final matchedRole = userRoles.firstWhere(
            (role) => role['roleCode'] == tokenRole,
            orElse: () => null,
          );

          if (matchedRole != null) {
            userData['roleLevel'] = matchedRole['roleLevel'] ?? -1;
          }

          return userData; // Returning full user data
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
