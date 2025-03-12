import 'dart:convert';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProductService {
  final String baseUrl = "https://localhost:5001";
  bool isLoading = true;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<dynamic> fetchProducts() async {
    final token = await getToken();
    if (token == null) return;

    final url = Uri.parse('$baseUrl/product');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      return;
    }
  }

  Future<Map<String, dynamic>?> createProduct(
    String productName,
    String productDescription,
    String productHighLights,
    double productPrice,
    int stockCount,
    String brandCode,
    String categoryCode,
    String firstImage,
    String secondImage,
    String thirdImage,
    String userCode,
  ) async {
    final token = await getToken();
    if (token == null) {
      showGlobalSnackBar(
          "Authentication token not found. Please log in again.");
      return null;
    }

    final url = Uri.parse('$baseUrl/product/create');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productName': productName,
          'productDescription': productDescription,
          'productHighLights': productHighLights,
          'productPrice': productPrice,
          'stockCount': stockCount,
          'brandCode': brandCode,
          'categoryCode': categoryCode,
          'firstImage': firstImage,
          'secondImage': secondImage,
          'thirdImage': thirdImage,
          'userCode': userCode,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        showGlobalSnackBar("Error: ${response.body}");
        return null;
      }
    } catch (e) {
      showGlobalSnackBar("An error occurred: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateProduct(
    String productCode,
    String productName,
    String productDescription,
    String productHighLights,
    double productPrice,
    String brandCode,
    String categoryCode,
    String userCode, // ✅ Ensure this is correctly passed
    String firstImage, // Add this parameter
    String secondImage, // Add this parameter
    String thirdImage, // Add this parameter
  ) async {
    final token = await getToken();
    if (token == null) {
      print("❌ Token is null!");
      return null;
    }

    final url = Uri.parse('$baseUrl/product/update');

    try {
      // ✅ Debugging log
      print("Updating product with images...");

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productCode': productCode,
          'productName': productName,
          'productDescription': productDescription,
          'productHighLights': productHighLights,
          'productPrice': productPrice,
          'brandCode': brandCode,
          'categoryCode': categoryCode,
          'userCode': userCode, // ✅ Ensure userCode is included
          'firstImage': firstImage, // Include first image
          'secondImage': secondImage, // Include second image
          'thirdImage': thirdImage, // Include third image
        }),
      );

      if (response.statusCode == 200) {
        showGlobalSnackBar('Product Updated Successfully!');
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print("❌ Update Failed: ${response.body}");
        showGlobalSnackBar('Failed to update product. Try again.');
        return null;
      }
    } catch (e) {
      print("🚨 Error in updateProduct: $e");
      return null;
    }
  }

  Future<bool> toggleProductStatus(String productCode) async {
    final token = await getToken();
    if (token == null) {
      showGlobalSnackBar("Unauthorized: Please log in again.");
      return false;
    }

    final encodedProductCode = base64Encode(utf8.encode(productCode));
    final url = Uri.parse(
        '$baseUrl/product/productstatus?ProductCode=$encodedProductCode');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> updateProductImages(String productCode, String firstImage,
      String secondImage, String thirdImage) async {
    final token = await getToken();
    if (token == null) return;
    final url = Uri.parse('$baseUrl/product/updateimages');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productCode': productCode,
          'firstImage': firstImage,
          'firstImageStatus': firstImage.isNotEmpty,
          'secondImage': secondImage,
          'secondImageStatus': secondImage.isNotEmpty,
          'thirdImage': thirdImage,
          'thirdImageStatus': thirdImage.isNotEmpty,
        }),
      );

      if (response.statusCode == 200) {
        showGlobalSnackBar('Product Images Updated Successfully!');
      } else {}
    } catch (e) {
      return;
    }
  }

  //   Future<Map<String, dynamic>?> fetchProduct(String productCode) async {
  //   final token = await getToken();
  //   if (token == null) return null;
  //   final url = Uri.parse(
  //       '$baseUrl/product/product?ProductCode=${base64Encode(utf8.encode(productCode))}');
  //   try {
  //     final response = await http.get(url, headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     });
  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }
}
