import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class Drawerservice {
  final String baseUrl = "https://localhost:5001";

  // Function to get the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<List<Map<String, dynamic>>> fetchMenuByRoleCode(
      String roleCode) async {
    if (roleCode.isEmpty) return [];

    final encodedRoleCode = base64Encode(utf8.encode(roleCode));
    final token = await getToken();
    if (token == null) return [];

    final url = Uri.parse(
        '$baseUrl/menuaccess/getAccessedMenus?RoleCode=$encodedRoleCode');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> accessList = jsonDecode(response.body);
        return _extractMenus(accessList);
      }
    } catch (e) {
      print("Error fetching menu: $e");
    }
    return [];
  }

  List<Map<String, dynamic>> _extractMenus(List<dynamic> menus) {
    List<Map<String, dynamic>> extractedMenus = [];
    for (var menu in menus) {
      extractedMenus.add({
        'menuCode': menu['menuCode'].toString(),
        'menuName': menu['menuName'] ?? '',
        'path': menu['path'] ?? '#',
        'subMenus':
            menu['subMenus'] != null ? _extractMenus(menu['subMenus']) : [],
      });
    }
    return extractedMenus;
  }
}
