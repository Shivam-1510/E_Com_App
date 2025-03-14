import 'dart:convert';

import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RouteService {
  final String baseUrl = "https://localhost:5001";
  bool isloading = true;

  //Funciton get the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    return token;
  }

  // Funtion to get Routes
  Future<dynamic> fetchRoute() async {
    final token = await getToken();
    if (token == null) {
      return;
    }
    final url = Uri.parse('$baseUrl/route');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final List<dynamic> routeData = jsonDecode(response.body);
        return routeData;
      } else {}
    } catch (e) {}
  }

  //Funtion to create routes
  Future<Map<String, dynamic>?> createRoute(
      String routeName, String path, bool isActive, String? parentCode) async {
    final token = await getToken();
    if (token == null) {
      return null;
    }
    final url = Uri.parse('$baseUrl/route/create');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'routeName': routeName,
          'path': path,
          'status': isActive,
          'parentCode': parentCode,
        }),
      );
      if (response.statusCode == 200) {
        showGlobalSnackBar('Route Created Successfully!');
        final Map<String, dynamic> routesData = jsonDecode(response.body);
        return routesData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Delete Function
  Future<void> deleteRotue(String routeCode) async {
    if (routeCode.isEmpty) {
      return;
    }
    final encodedRouteCode = base64Encode(utf8.encode(routeCode));
    final token = await getToken();
    if (token == null) {
      return;
    }
    final url =
        Uri.parse('$baseUrl/route/delete?routeCode=${encodedRouteCode}');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'applicaition/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        showGlobalSnackBar('Route Deleted Successfully!');
      } else {
        showGlobalSnackBar('Failed to delete Route.');
      }
    } catch (e) {}
  }

  // Update the routes
  Future<Map<String, dynamic>?> updateRoute(int id, String routeCode,
      String routeName, String path, bool isActive, String parentCode) async {
    final token = await getToken();
    if (token == null) {
      return null;
    }
    final url = Uri.parse('$baseUrl/route/update');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id': id,
          'routeCode': routeCode,
          'routeName': routeName,
          'path': path,
          'status': isActive,
          'parentCode': parentCode,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> routeData = jsonDecode(response.body);
        showGlobalSnackBar('Route updated Successfully! ');
        return routeData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Funtion to get subroutes and routes
  Future<dynamic> fetchRouteandSubroute() async {
    final token = await getToken();
    if (token == null) {
      return;
    }
    final url = Uri.parse('$baseUrl/route/getroutesandsubroutes');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final List<dynamic> routeData = jsonDecode(response.body);
        return routeData;
      } else {}
    } catch (e) {}
  }
}
