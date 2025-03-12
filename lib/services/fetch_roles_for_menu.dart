import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String baseUrl = "https://localhost:5001";

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    return token;
  }

  Future<List<Map<String, String>>> fetchRoles() async {
    final token = await getToken(); // Get the token from shared preferences
    if (token == null) {
      return [];
    }

    final url = Uri.parse('$baseUrl/userrole'); // API endpoint for roles

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> rolesData = jsonDecode(response.body);
        return rolesData.map((role) {
          return {
            'roleCode': role['roleCode']?.toString() ?? 'N/A',
            'roleName': role['roleName']?.toString() ?? 'N/A',
            'roleLevel': role['roleLevel']?.toString() ?? 'N/A',
          };
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>?> fetchUsers(String roleCode) async {
    final token = await getToken();
    if (token == null) {
      return null;
    }

    final encodedRoleCode = base64Encode(utf8.encode(roleCode));
    final url = Uri.parse('$baseUrl/user/users?roleCode=$encodedRoleCode');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> rolesData = jsonDecode(response.body);
        return rolesData.map((role) {
          return {
            'name': role['user']['name'] ?? 'N/A',
            'mobile': role['user']['mobileNumber'] ?? 'N/A',
            'status': role['user']['isActive'] ?? 'N/A',
            'lastLogin': role['user']['lastLogin'] ?? 'N/A',
            'createdBy': role['user']['createdBy'] ?? 'N/A',
            'roleLevel': role['userRole']['roleLevel'] ?? 'N/A',
            'userCode': role['user']['userCode'] ?? 'N/A',
          };
        }).toList();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
