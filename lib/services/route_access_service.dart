import 'dart:convert';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RouteAccessService {
  final String baseUrl = "https://localhost:5001";

  // function to get the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    return token;
  }

  Future<List<Map<String, dynamic>>> fetchRouteByRoleCode(
      String roleCode) async {
    if (roleCode.isEmpty) {
      return [];
    }

    final encodedRoleCode = base64Encode(utf8.encode(roleCode));
    final token = await getToken();
    if (token == null) {
      return [];
    }

    final url = Uri.parse(
        '$baseUrl/routeaccess/getaccessedroutes?RoleCode=$encodedRoleCode');

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

        //  Recursive function to extract all routes and subRoutes
        List<Map<String, dynamic>> extractRoutes(List<dynamic> routes) {
          List<Map<String, dynamic>> extractedRoutes = [];
          for (var route in routes) {
            extractedRoutes.add({
              'routeCode': route['routeCode'].toString(),
              'status': route['status'] ?? false,
            });

            // Fix: Corrected "subRoutes" key (was "subroutes")
            if (route['subRoutes'] != null && route['subRoutes'].isNotEmpty) {
              extractedRoutes.addAll(extractRoutes(route['subRoutes']));
            }
          }
          return extractedRoutes;
        }

        return extractRoutes(accessList);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Create Route access dene keliye
  Future<Map<String, dynamic>?> createRouteAccess(
      List<Map<String, dynamic>> routeAccessList) async {
    final token = await getToken();
    if (token == null) {
      return null;
    }
    final url = Uri.parse('$baseUrl/routeaccess/createandupdate');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(routeAccessList),
      );
      if (response.statusCode == 200) {
        showGlobalSnackBar('Route Access Updated!');
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
