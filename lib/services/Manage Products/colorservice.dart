import 'dart:convert';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Colorservice {
  final String baseUrl = "https://localhost:5001";
  bool isLoading = true;

  // Funtion to get the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    return token;
  }

  // Funtion to get color
  Future<dynamic> fetchColor() async {
    final token = await getToken();
    if (token == null) {
      return;
    }
    final url = Uri.parse('$baseUrl/color');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final List<dynamic> colorData = jsonDecode(response.body);
        return colorData;
      }
    } catch (e) {
      return;
    }
  }

  // Funtion create color
  Future<Map<String, dynamic>?> createColor(String colorName) async {
    final token = await getToken();
    if (token == null) {
      return null;
    }

    final url = Uri.parse('$baseUrl/color/create');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'colorName': colorName,
        }),
      );
      if (response.statusCode == 200) {
        showGlobalSnackBar('Color Created Successfully!');
        final Map<String, dynamic> colorData = jsonDecode(response.body);
        return colorData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Delete color
  Future<void> deletecolor(String colorCode) async {
    if (colorCode.isEmpty) {
      return;
    }
    final encodedColorCode = base64Encode(utf8.encode(colorCode));
    final token = await getToken();
    if (token == null) {
      return;
    }
    final url =
        Uri.parse('$baseUrl/color/delete?ColorCode=${encodedColorCode}');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        showGlobalSnackBar('Color Deleted Successfully!');
      } else {
        showGlobalSnackBar('Failed to delete Color!');
      }
    } catch (e) {
      return;
    }
  }

  // Update Color
  Future<Map<String, dynamic>?> updateColor(
      String colorCode, String colorName) async {
    final token = await getToken();
    if (token == null) {
      return null;
    }

    final url = Uri.parse('$baseUrl/color/update');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'colorCode': colorCode,
          'colorName': colorName,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> colorData = jsonDecode(response.body);
        showGlobalSnackBar('Color Created Successfully!');
        fetchColor();
        return colorData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
