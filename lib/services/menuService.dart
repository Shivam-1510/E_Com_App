import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_comapp/utils/snackbar_util.dart';

class MenuService {
  final String baseUrl = "https://localhost:5001";
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
      } else {}
    } catch (e) {}
  }

  // Function to create menus

  Future<Map<String, dynamic>?> createMenu(String menuName, String path,
      String icon, bool isActive, String? parentCode) async {
    final token = await getToken();
    if (token == null) {
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
        showGlobalSnackBar('Menu Created Successfully!');
        final Map<String, dynamic> menusData = jsonDecode(response.body);
        return menusData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Delete Funciton
  Future<void> deleteMenu(String menuCode) async {
    if (menuCode.isEmpty) {
      return;
    }
    final encodedMenuCode = base64Encode(utf8.encode(menuCode));
    final token = await getToken();
    if (token == null) {
      return;
    }
    final url = Uri.parse('$baseUrl/menu/delete?menuCode=$encodedMenuCode');
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
    } catch (e) {}
  }

  // Update the menu
  Future<Map<String, dynamic>?> updateMenu(
    String menuCode,
    String menuName,
    String path,
    String icon,
    bool isActive,
    String parentCode,
  ) async {
    final token = await getToken();
    if (token == null) {
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
          'menuCode': menuCode,
          'menuName': menuName,
          'path': path,
          'icon': icon,
          'status': isActive,
          'parentCode': parentCode,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> menuData = jsonDecode(response.body);
        showGlobalSnackBar('Menu Updated Successfully!');
        fetchMenu();
        return menuData;
      } else {
        return null;
      }
    } catch (e) {
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
      } else {}
    } catch (e) {}
  }
}
