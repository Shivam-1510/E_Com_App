import 'dart:convert';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MenuAccessService {
  final String baseUrl = "https://localhost:7157";

  // Function to get the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    return token;
  }
 
  // Function to get menu access through role code
  Future<List<Map<String, dynamic>>> fetchMenuByRoleCode(String roleCode) async {
  if (roleCode.isEmpty) {
    print('Invalid roleCode provided: $roleCode');
    return [];
  }

  final encodedRoleCode = base64Encode(utf8.encode(roleCode));
  final token = await getToken();
  if (token == null) {
    print('No token found. Please login.');
    return [];
  }

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
      
      // Recursive function to extract all submenus
      List<Map<String, dynamic>> extractMenus(List<dynamic> menus) {
        List<Map<String, dynamic>> extractedMenus = [];

        for (var menu in menus) {
          extractedMenus.add({
            'menuCode': menu['menuCode'].toString(),
            'status': menu['status'] ?? false,
          });

          // Check if the menu has submenus
          if (menu['subMenus'] != null && menu['subMenus'].isNotEmpty) {
            extractedMenus.addAll(extractMenus(menu['subMenus']));
          }
        }

        return extractedMenus;
      }

      return extractMenus(accessList);
    } else {
      print('Failed to fetch menu access. Status: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error fetching menu: $e');
    return [];
  }
}


  // Create menu access dene ke liye
  Future<Map<String, dynamic>?> createMenuAccess(
      List<Map<String, dynamic>> menuAccessList) async {
    final token = await getToken();
    if (token == null) {
      print('No token found. Please log in.');
      return null;
    }

    final url = Uri.parse('$baseUrl/menuaccess/createandupdate');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(menuAccessList),
      );

      if (response.statusCode == 200) {
        showGlobalSnackBar('Menu Access Updated!');
        return jsonDecode(response.body);
      } else {
        print(
            "Failed to update menu access. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error updating menu access: $e");
      return null;
    }
  }
}
