import 'dart:convert';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Sizeservice {
  final String baseUrl = "https://localhost:5001";
  bool isLoading = true;

  // Funtion to get the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    return token;
  }

  // Funtion to get Size
  Future<dynamic> fetchSize() async {
    final token = await getToken();
    if (token == null) {
      return;
    }

    final url = Uri.parse('$baseUrl/size');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final List<dynamic> sizeData = jsonDecode(response.body);
        return sizeData;
      }
    } catch (e) {
      return;
    }
  }

  // funtion to create size
  Future<Map<String, dynamic>?> createSize(
      String sizeName, String sizeShortName) async {
    final token = await getToken();
    if (token == null) {
      return null;
    }
    final url = Uri.parse('$baseUrl/size/create');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'sizeName': sizeName,
          'sizeShortName': sizeShortName,
        }),
      );
      if (response.statusCode == 200) {
        showGlobalSnackBar('Size Created Successfully!');
        final Map<String, dynamic> sizeData = jsonDecode(response.body);
        return sizeData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Delete Size
  Future<void> deleteSize(String sizeCode) async {
    if (sizeCode.isEmpty) {
      return;
    }
    final encodedSizeCode = base64Encode(utf8.encode(sizeCode));
    final token = await getToken();
    if (token == null) {
      return;
    }

    final url = Uri.parse('$baseUrl/size/delete?SizeCode=${encodedSizeCode}');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        showGlobalSnackBar('Size Deleted Successfully!');
      } else {
        showGlobalSnackBar('Failed to delete Size!');
      }
    } catch (e) {
      return;
    }
  }

  // Update Size
  Future<Map<String, dynamic>?> updateSize(
    String sizeCode,
    String sizeShortName,
    String sizeName,
  ) async {
    final token = await getToken();
    if (token == null) {
      return null;
    }

    final url = Uri.parse('$baseUrl/size/update');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'sizeCode': sizeCode,
          'sizeName': sizeName,
          'sizeShortName': sizeShortName,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> sizeData = jsonDecode(response.body);
        showGlobalSnackBar('Size Updated Successfully!');
        fetchSize();
        return sizeData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
