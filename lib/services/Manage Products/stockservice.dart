import 'dart:convert';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class StockService {
  final String baseUrl = "https://localhost:5001";

  // Function to get the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Function to fetch stock items by ProductCode
  Future<dynamic> fetchStock(String productCode) async {
    final token = await getToken();
    if (token == null) return null;

    String encodedProductCode = base64Encode(utf8.encode(productCode));
    final url = Uri.parse('$baseUrl/stock?ProductCode=$encodedProductCode');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // Function to fetch a specific stock item by StockCode
  Future<dynamic> getStock(String stockCode) async {
    final token = await getToken();
    if (token == null) return;

    String encodedStockCode = base64Encode(utf8.encode(stockCode));
    final url = Uri.parse('$baseUrl/stock/stock?StockCode=$encodedStockCode');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        showGlobalSnackBar('Stock not found!');
      }
    } catch (e) {
      return;
    }
  }

  // Function to create a stock entry
  Future<bool> createStock(String productCode, String sizeCode,
      String colorCode, int stockCount) async {
    final token = await getToken();
    if (token == null) return false;

    final url = Uri.parse('$baseUrl/stock/create');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productCode': productCode,
          'sizeCode': sizeCode,
          'colorCode': colorCode,
          'stockCount': stockCount,
        }),
      );

      if (response.statusCode == 200) {
        showGlobalSnackBar('Stock Created Successfully!');
        return true;
      } else {
        showGlobalSnackBar('Failed to create stock!');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Function to update stock count
  Future<bool> updateStock(String stockCode, int stockCount) async {
    final token = await getToken();
    if (token == null) return false;

    String encodedStockCode = base64Encode(utf8.encode(stockCode));
    String encodedStockCount = base64Encode(utf8.encode(stockCount.toString()));

    final url = Uri.parse(
        '$baseUrl/stock/update?StockCode=$encodedStockCode&StockCount=$encodedStockCount');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        showGlobalSnackBar('Stock Updated Successfully!');
        return true;
      } else {
        showGlobalSnackBar('Failed to update stock!');
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
