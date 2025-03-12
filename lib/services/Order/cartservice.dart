import 'dart:convert';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CartService {
  final String baseUrl = "https://localhost:5001";

  // Function to get the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    return token;
  }

  // Fetch all cart items
  Future<dynamic> fetchCartItems(String userCode) async {
    final token = await getToken();
    if (token == null) return;

    final encodedUserCode = base64Encode(utf8.encode(userCode));
    final url = Uri.parse('$baseUrl/cart?UserCode=$encodedUserCode');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        showGlobalSnackBar('Failed to fetch cart items.');
      }
    } catch (e) {
      showGlobalSnackBar('Error fetching cart items.');
    }
  }

  // Fetch a specific cart item
  Future<dynamic> fetchCartItem(String cartCode) async {
    final token = await getToken();
    if (token == null) return;

    final encodedCartCode = base64Encode(utf8.encode(cartCode));
    final url = Uri.parse('$baseUrl/cart/cartitem?CartCode=$encodedCartCode');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        showGlobalSnackBar('Failed to fetch cart item.');
      }
    } catch (e) {
      showGlobalSnackBar('Error fetching cart item.');
    }
  }

  // Add item to cart
  Future<Map<String, dynamic>?> addCartItem(
      Map<String, dynamic> cartItem) async {
    final token = await getToken();
    if (token == null) {
      return null;
    }

    final url = Uri.parse('$baseUrl/cart/addcartitem');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(cartItem),
      );

      if (response.statusCode == 200) {
        showGlobalSnackBar('Item added to cart successfully!');
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        showGlobalSnackBar('Failed to add item to cart.');
        return null;
      }
    } catch (e) {
      showGlobalSnackBar('Error adding item to cart.');
      return null;
    }
  }

  // Update cart item
  Future<Map<String, dynamic>?> updateCartItem(
      Map<String, dynamic> cartItem) async {
    final token = await getToken();
    if (token == null) {
      return null;
    }

    final url = Uri.parse('$baseUrl/cart/updatecartitem');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(cartItem),
      );

      if (response.statusCode == 200) {
        showGlobalSnackBar('Cart item updated successfully!');
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        showGlobalSnackBar('Failed to update cart item.');
        return null;
      }
    } catch (e) {
      showGlobalSnackBar('Error updating cart item.');
      return null;
    }
  }

  // Remove item from cart
  Future<void> removeCartItem(String cartCode) async {
    if (cartCode.isEmpty) return;

    final encodedCartCode = base64Encode(utf8.encode(cartCode));
    final token = await getToken();
    if (token == null) return;

    final url = Uri.parse('$baseUrl/cart/remove?CartCode=$encodedCartCode');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        showGlobalSnackBar('Item removed from cart successfully!');
      } else {
        showGlobalSnackBar('Failed to remove cart item.');
      }
    } catch (e) {
      showGlobalSnackBar('Error removing cart item.');
    }
  }
}
