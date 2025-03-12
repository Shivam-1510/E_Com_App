import 'dart:convert';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Categoryservice {
  final String baseUrl = "https://localhost:5001";
  bool isLoading = true;

  // Function to get the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    return token;
  }

  // Funtion to get Category
  Future<List<Map<String, dynamic>>?> fetchCategory() async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/category');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> categoryData = jsonDecode(response.body);
        return categoryData
            .map((category) => Map<String, dynamic>.from(category))
            .toList();
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
    return null;
  }

  // function to create category
  Future<Map<String, dynamic>?> createCategory(
    String categoryName,
  ) async {
    final token = await getToken();
    if (token == null) {
      return null;
    }

    final url = Uri.parse('$baseUrl/category/create');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'categoryName': categoryName,
        }),
      );
      if (response.statusCode == 200) {
        showGlobalSnackBar("Category Created Successfully!");
        final Map<String, dynamic> categoryData = jsonDecode(response.body);
        return categoryData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Delete Category
  Future<void> delteCategory(String categoryCode) async {
    if (categoryCode.isEmpty) {
      return;
    }
    final encodedCategoryCode = base64Encode(utf8.encode(categoryCode));
    final token = await getToken();
    if (token == null) {
      return;
    }
    final url = Uri.parse(
        '$baseUrl/category/delete?CategoryCode=${encodedCategoryCode}');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        showGlobalSnackBar('Category Deleted Successfully!');
      } else {
        showGlobalSnackBar('Failed to delete Category!');
      }
    } catch (e) {
      return;
    }
  }

  // Update Category
  Future<Map<String, dynamic>?> updateCategory(
      String categoryCode, String categoryName) async {
    final token = await getToken();
    if (token == null) {
      return null;
    }

    final url = Uri.parse('$baseUrl/category/update');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'categoryCode': categoryCode,
          'categoryName': categoryName,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> categoryData = jsonDecode(response.body);
        showGlobalSnackBar('Category Updated Successfully!');
        fetchCategory();
        return categoryData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
