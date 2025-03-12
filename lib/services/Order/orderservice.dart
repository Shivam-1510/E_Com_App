import 'dart:convert';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OrderService {
  final String baseUrl = "https://localhost:5001";

  // Function to get the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Fetch a specific order
  Future<dynamic> fetchOrder(String orderCode) async {
    final token = await getToken();
    if (token == null) return;

    final encodedOrderCode = base64Encode(utf8.encode(orderCode));
    final url = Uri.parse('$baseUrl/order/order?OrderCode=$encodedOrderCode');

    try {
      final response = await http.put(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        showGlobalSnackBar('Failed to fetch order.');
      }
    } catch (e) {
      showGlobalSnackBar('Error fetching order.');
    }
  }

  // Fetch all orders
  Future<List<dynamic>> fetchOrders() async {
    final token = await getToken(); // Token fetch karo
    if (token == null) {
      showGlobalSnackBar("Authentication failed. Please log in.");
      return [];
    }

    final url = Uri.parse('$baseUrl/order/getorders'); // ✅ Correct URL

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ✅ Token added
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData is List) {
          return jsonData;
        } else {
          return []; // ✅ Ensure return is a list
        }
      } else {
        print("Error fetching orders: ${response.statusCode}");
        showGlobalSnackBar('Failed to fetch orders.');
        return [];
      }
    } catch (e) {
      print("Exception: $e");
      showGlobalSnackBar('Error fetching orders.');
      return [];
    }
  }

  // Add a new order
  Future<Map<String, dynamic>?> addOrder(Map<String, dynamic> orderData) async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/order/addorder');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200) {
        showGlobalSnackBar('Order placed successfully!');
        return jsonDecode(response.body);
      } else {
        showGlobalSnackBar('Failed to place order.');
        return null;
      }
    } catch (e) {
      showGlobalSnackBar('Error placing order.');
      return null;
    }
  }

  // Ship an order
  Future<void> shipOrder(String orderCode) async {
    final token = await getToken();
    if (token == null) return;

    final encodedOrderCode = base64Encode(utf8.encode(orderCode));
    final url =
        Uri.parse('$baseUrl/order/shiporder?OrderCode=$encodedOrderCode');

    try {
      final response = await http.put(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        showGlobalSnackBar('Order shipped successfully!');
      } else {
        showGlobalSnackBar('Failed to ship order.');
      }
    } catch (e) {
      showGlobalSnackBar('Error shipping order.');
    }
  }
}
