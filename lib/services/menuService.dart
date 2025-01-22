import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MenuService {
  final String baseUrl = "https://localhost:7157";
  bool isLoading = true;

  // Function to get the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    return token;
  }

  // funtion to get menus
  Future<dynamic> fetchMenu() async {
    final token = await getToken();
    if (token == null) {
      return;
    }
    final url = Uri.parse('$baseUrl/menu');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final List<dynamic> menuData = jsonDecode(response.body);
        return menuData;
      } else {
        print('Failed to fetch menus: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching menus: $e');
    }
  }

  // Function to create menus
  Future<dynamic> createMenu(
      String menuName, String path, String icon, bool isActive) async {
    final token = await getToken();
    if (token == null) {
      print('No token found . Please log in.');
      return;
    }
    final url = Uri.parse('$baseUrl/menu/create');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'menuName': menuName,
          'path': path,
          'icon': icon,
          'status': isActive,
        }),
      );
      if (response.statusCode == 200) {
        final List<dynamic> menusData = jsonDecode(response.body);
        
        return menusData;
        
      } else {
        print("Failed to create menu. Staus code:${response.statusCode}");
        
      }
    } catch (e) {
      print('Error creating menu:$e');
    }
  }
}
