import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Library for decoding JWT tokens.

class UserRoleService {
  final String baseUrl = "https://localhost:7157";

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
      print("Error decoding token: $e");
      return null;
    }
  }

  // Function to fetch user role level based on token and API response
  Future<int?> getUserRoleLevel() async {
    final token = await getToken();

    if (token == null) {
      print("No token found! User might not be logged in.");
      return null; // Handle unauthorized access
    }

    // Decode the JWT token to extract claims
    final decodedToken = decodeToken(token);
    if (decodedToken == null || !decodedToken.containsKey('role')) {
      print("Invalid or missing role in token!");
      return null;
    }

    final String tokenRole = decodedToken['role'];

    // Make API call to fetch user details by claim
    final url = Uri.parse('$baseUrl/user/userbyclaim');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Check API response status
      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);

        // Validate user roles data
        if (userData.containsKey('userRoles') &&
            userData['userRoles'] is List<dynamic>) {
          final List<dynamic> userRoles = userData['userRoles'];

          // Find matching role based on roleCode
          final matchedRole = userRoles.firstWhere(
            (role) => role['roleCode'] == tokenRole,
            orElse: () => null,
          );

          // Return the role level if found
          if (matchedRole != null) {
            final int roleLevel =
                matchedRole['roleLevel'] ?? -1; // Default to -1 if missing
            print("Role Level: $roleLevel");
            return roleLevel;
          } else {
            print("No matching role found for roleCode: $tokenRole");
            return null;
          }
        } else {
          print("No valid 'userRoles' data found in the response!");
          return null;
        }
      } else {
        print(
            "Failed to fetch user roles. Status Code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching user role level: $e");
      return null;
    }
  }
}
