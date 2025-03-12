import 'dart:convert';

import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Brandservice {
  final String baseUrl = "https://localhost:5001";
  bool isLoading = true;

  // Function to get the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    return token;
  }

  // function to get brand
  Future<List<Map<String, dynamic>>?> fetchBrand() async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/brand');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> brandData = jsonDecode(response.body);
        // Ensure the response is in the desired format
        return brandData
            .map((brand) => Map<String, dynamic>.from(brand))
            .toList();
      }
    } catch (e) {
      print("Error fetching brands: $e");
    }
    return null;
  }

  // Funtion to create brand
  Future<Map<String, dynamic>?> createBrand(
      String brandName, String brandDetails) async {
    final token = await getToken();
    if (token == null) {
      return null;
    }
    final url = Uri.parse('$baseUrl/brand/create');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'brandName': brandName,
          'brandDetails': brandDetails,
        }),
      );
      if (response.statusCode == 200) {
        showGlobalSnackBar('Brand Created Successfully!');
        final Map<String, dynamic> brandData = jsonDecode(response.body);
        return brandData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Delete Brand
  Future<void> deleteBrand(String brandCode) async {
    if (brandCode.isEmpty) {
      return;
    }
    final encodedBrandCode = base64Encode(utf8.encode(brandCode));
    final token = await getToken();
    if (token == null) {
      return;
    }
    final url =
        Uri.parse('$baseUrl/brand/delete?BrandCode=${encodedBrandCode}');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        showGlobalSnackBar('Brand Deleted Successfully!');
      } else {
        showGlobalSnackBar('Failed to delete Brand.');
      }
    } catch (e) {}
  }

  // Update brand
  Future<Map<String, dynamic>?> updateBrand(
      String brandCode, String brandName, String brandDetails) async {
    final token = await getToken();
    if (token == null) {
      return null;
    }
    final url = Uri.parse('$baseUrl/brand/update');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'brandCode': brandCode,
          'brandName': brandName,
          'brandDetails': brandDetails,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> brandData = jsonDecode(response.body);
        showGlobalSnackBar('Brand Updated Successfully!');
        fetchBrand();
        return brandData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
