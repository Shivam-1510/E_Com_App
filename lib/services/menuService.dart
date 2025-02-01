import 'dart:convert';

import 'package:e_comapp/utils/snackbar_util.dart';
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

  Future<Map<String, dynamic>?> createMenu(String menuName, String path,
      String icon, bool isActive, String? parentCode) async {
    final token = await getToken();
    if (token == null) {
      print('No token found . Please log in.');
      return null;
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
          "parentCode": parentCode,
        }),
      );
      if (response.statusCode == 200) {
        showGlobalSnackBar('Menu Created Succesfully!');
        final Map<String, dynamic> menusData = jsonDecode(response.body);
        return menusData;
      } else {
        print("Failed to create menu. Staus code:${response.statusCode}");
        return null;
      }
    } catch (e) {
      print('Error creating menu:$e');
      return null;
    }
  }

  // Delete Funciton
  Future<void> deleteMenu(String menuCode) async {
    if (menuCode.isEmpty) {
      print("Invalid menuCode provided: $menuCode");
      return;
    }
    final encodedMenuCode = base64Encode(utf8.encode(menuCode));
    final token = await getToken();
    if (token == null) {
      print('No token found. Please login.');
      return;
    }
    final url = Uri.parse('$baseUrl/menu/delete?menuCode=${encodedMenuCode}');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        showGlobalSnackBar('Menu Deleted Successfully!');
      } else {
        showGlobalSnackBar('Failed to delete Menu.');
      }
    } catch (e) {
      print('Eror deleting menu: $e');
    }
  }

  // Update the menu
  Future<Map<String, dynamic>?> updateMenu(int id, String menuCode,
      String menuName, String path, String icon, bool isActive) async {
    final token = await getToken();
    if (token == null) {
      print('No token found. Please log in.');
      return null;
    }

    final url = Uri.parse('$baseUrl/menu/update');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id': id,
          'menuCode': menuCode,
          'menuName': menuName,
          'path': path,
          'icon': icon,
          'status': isActive,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> menuData = jsonDecode(response.body);
        showGlobalSnackBar('Menu Updated Successfully!');
        fetchMenu();
        return menuData;
      } else {
        print('Failed to update menu. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating menu: $e');
      return null;
    }
  }
  // funtion to get menus and submenus
  Future<dynamic> fetchMenuandSubmenu() async {
    final token = await getToken();
    if (token == null) {
      return;
    }
    final url = Uri.parse('$baseUrl/menu/getmenusandsubmenus');

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
}
