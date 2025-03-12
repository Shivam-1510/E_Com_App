import 'dart:convert';
import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/services/Order/cartservice.dart';
import 'package:e_comapp/services/Order/orderservice.dart';
import 'package:e_comapp/services/getloginuesrrole.dart';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';

class Cartscreen extends StatefulWidget {
  const Cartscreen({super.key});

  @override
  State<Cartscreen> createState() => _CartscreenState();
}

class _CartscreenState extends State<Cartscreen> {
  final CartService _cartService = CartService();
  final UserRoleService _userRoleService = UserRoleService();
  final OrderService _orderService = OrderService();
  dynamic userCode;
  List<dynamic> cartItems = [];
  Set<String> selectedItems = {}; // Track selected items

  Future<void> fetchLoggedInUserDetails() async {
    final userDetails = await _userRoleService.getUserDetails();
    if (userDetails != null) {
      setState(() {
        userCode = userDetails['user']['userCode']?.toString() ?? 'N/A';
      });
      fetchCartItems();
    }
  }

  Future<void> fetchCartItems() async {
    if (userCode != null && userCode != 'N/A') {
      final items = await _cartService.fetchCartItems(userCode);
      setState(() {
        cartItems = items;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLoggedInUserDetails();
  }

  void showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Payment Method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Cash on Delivery (COD)'),
                onTap: () {
                  Navigator.pop(context); // Close payment dialog
                  showConfirmOrderDialog(context, 'COD');
                },
              ),
              ListTile(
                title: Text('UPI'),
                onTap: () {
                  // Implement UPI payment flow here if needed
                  showGlobalSnackBar("UPI Payment is under development!");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showConfirmOrderDialog(BuildContext context, String paymentMethod) {
    // Fetch selected items with details
    List<Map<String, dynamic>> selectedProducts = cartItems
        .where((item) => selectedItems.contains(item['cartCode']))
        .map((item) => item as Map<String, dynamic>)
        .toList();

    if (selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No items selected!")));
      return;
    }

    double totalPrice = selectedProducts.fold(0.0, (sum, item) {
      double price = double.tryParse(
              item['product']?['productPrice']?.toString() ?? "0.0") ??
          0.0;
      int quantity = int.tryParse(item['count']?.toString() ?? "1") ?? 1;
      // String name =
      //     item['product']?['productName']?.toString() ?? 'Unknown Item';

      return sum + (price * quantity);
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Order'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...selectedProducts.map((item) {
                  double price = double.tryParse(
                          item['product']?['productPrice']?.toString() ??
                              "0.0") ??
                      0.0;
                  int quantity =
                      int.tryParse(item['count']?.toString() ?? "1") ?? 1;
                  String name = item['product']?['productName']?.toString() ??
                      'Unknown Item';
                  String imageBase64 = item['product']?['firstImage'] ?? '';

                  return ListTile(
                    leading: imageBase64.isNotEmpty
                        ? Image.memory(
                            base64Decode(imageBase64),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.image_not_supported),
                    title: Text(name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Quantity: $quantity'),
                    trailing:
                        Text('₹ ${(price * quantity).toStringAsFixed(2)}'),
                  );
                }).toList(),
                Divider(),
                Text(
                  'Total: ₹ ${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                placeOrder(selectedProducts, paymentMethod);
                Navigator.pop(context);
              },
              child: Text('Confirm Order'),
            ),
          ],
        );
      },
    );
  }

  void placeOrder(
      List<Map<String, dynamic>> selectedProducts, String paymentMethod) async {
    if (userCode == 'N/A') {
      return;
    }

    List<Map<String, dynamic>> orderItems = selectedProducts.map((item) {
      return {
        "cartCode": item['cartCode'] ?? "",
        "productCode": item['productCode'] ?? "",
        "userCode":
            userCode, 
        "sizeCode": item['sizeCode'] ?? "",
        "colorCode": item['colorCode'] ?? "",
        "count": (item['quantity'] as num?)?.toInt() ?? 1,
      };
    }).toList();

    Map<String, dynamic> orderData = {
      "orderItems": orderItems,
      "paymentMethod": paymentMethod == "COD" ? 0 : 1
    };
    final result = await _orderService.addOrder(orderData);
    fetchCartItems();
    if (result != null) {
      // print("✅ Order placed successfully!");
    } else {
      // print("❌ Failed to place order.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Cart',
            style: TextStyle(color: whiteColor, fontFamily: bold),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 10),
          child: cartItems.isEmpty
              ? Center(
                  child: Text(
                  "Cart is Empty",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          final String base64Image =
                              item['product']['firstImage'] ?? '';
                          final String price =
                              item['product']['productPrice']?.toString() ??
                                  'N/A';

                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: selectedItems
                                        .contains(item['cartCode']),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedItems.add(item['cartCode']);
                                        } else {
                                          selectedItems
                                              .remove(item['cartCode']);
                                        }
                                      });
                                    },
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: base64Image.isNotEmpty
                                        ? Image.memory(
                                            base64Decode(base64Image),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(Icons.image_not_supported,
                                            size: 100),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['product']['productName'],
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                            "Size: ${item['size']['sizeName']}",
                                            style: TextStyle(fontSize: 14)),
                                        Text(
                                            "Color: ${item['color']['colorName']}",
                                            style: TextStyle(fontSize: 14)),
                                        Text(
                                          '₹ $price',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.red, width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove,
                                                  color: Colors.red),
                                              onPressed: () async {
                                                if (item['count'] > 1) {
                                                  await _cartService
                                                      .updateCartItem({
                                                    "userCode": userCode,
                                                    "cartCode":
                                                        item['cartCode'],
                                                    "productCode":
                                                        item['product']
                                                            ['productCode'],
                                                    "sizeCode":
                                                        item['sizeCode'],
                                                    "colorCode":
                                                        item['colorCode'],
                                                    "count": item['count'] - 1,
                                                  });
                                                  fetchCartItems();
                                                } else {
                                                  await _cartService
                                                      .removeCartItem(
                                                          item['cartCode']);
                                                  fetchCartItems();
                                                }
                                              },
                                            ),
                                            Text(
                                              item['count'].toString(),
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add,
                                                  color: Colors.red),
                                              onPressed: () async {
                                                await _cartService
                                                    .updateCartItem({
                                                  "userCode": userCode,
                                                  "cartCode": item['cartCode'],
                                                  "productCode": item['product']
                                                      ['productCode'],
                                                  "sizeCode": item['sizeCode'],
                                                  "colorCode":
                                                      item['colorCode'],
                                                  "count": item['count'] + 1,
                                                });
                                                fetchCartItems();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red, size: 30),
                                        onPressed: () async {
                                          await _cartService
                                              .removeCartItem(item['cartCode']);
                                          fetchCartItems();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: selectedItems.isNotEmpty
                            ? () {
                                showPaymentDialog(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Place Order',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
