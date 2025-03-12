import 'dart:convert';
import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/services/Order/cartservice.dart';
import 'package:e_comapp/services/getloginuesrrole.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';

class Cartscreen extends StatefulWidget {
  const Cartscreen({super.key});

  @override
  State<Cartscreen> createState() => _CartscreenState();
}

class _CartscreenState extends State<Cartscreen> {
  final CartService _cartService = CartService();
  final UserRoleService _userRoleService = UserRoleService();
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
              ? Center(child: CircularProgressIndicator())
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
                        onPressed: selectedItems.isNotEmpty ? () {} : null,
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
