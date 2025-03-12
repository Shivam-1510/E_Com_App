import 'dart:convert';
import 'dart:typed_data';
import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/consts/list.dart';
import 'package:e_comapp/services/Manage%20Products/stockservice.dart';
import 'package:e_comapp/services/Order/cartservice.dart';
import 'package:e_comapp/services/getloginuesrrole.dart';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:e_comapp/views/widgets_common/our_button.dart';
import 'package:flutter/material.dart';

class ItemsDetails extends StatefulWidget {
  final Map<String, dynamic> product;
  const ItemsDetails({Key? key, required this.product}) : super(key: key);
  @override
  _ItemsDetailsState createState() => _ItemsDetailsState();
}

class _ItemsDetailsState extends State<ItemsDetails> {
  Uint8List? mainImage;
  Uint8List? subImage1;
  Uint8List? subImage2;
  List<Map<String, dynamic>> stockData = [];
  final StockService _stockService = StockService();
  final CartService _cartService = CartService();
  final UserRoleService _userRoleService = UserRoleService();
  dynamic userCode;
  int? userRoleLevel;
  List<dynamic> cartItems = [];

  // Track selected color and size
  String? selectedColor;
  String? selectedSize;

  // Function to fetch and set stock data
  Future<void> getStock(String productCode) async {
    var data = await _stockService.fetchStock(productCode);
    if (data != null && data is List) {
      setState(() {
        stockData = List<Map<String, dynamic>>.from(data);
      });
    }
  }

  Future<void> fetchLoggedInUserDetails() async {
    final userDetails =
        await _userRoleService.getUserDetails(); // Fetch user data
    if (userDetails != null) {
      setState(() {
        // Extract userCode from 'user' object
        userCode = userDetails['user']['userCode']?.toString() ?? 'N/A';
        // Extract roleLevel from 'userRoles' array
        if (userDetails['userRoles'] != null &&
            userDetails['userRoles'].isNotEmpty) {
          userRoleLevel = userDetails['userRoles'][0]['roleLevel'] ?? 0;
        } else {
          userRoleLevel = 0; // Default value if roleLevel is missing
        }
      });
    } else {}
  }

  @override
  void initState() {
    super.initState();
    _decodeImages();
    getStock(widget.product['productCode']);
    fetchLoggedInUserDetails();
  }

  void _decodeImages() {
    try {
      setState(() {
        mainImage = base64Decode(widget.product['firstImage']);
        subImage1 = base64Decode(widget.product['secondImage']);
        subImage2 = base64Decode(widget.product['thirdImage']);
      });
    } catch (e) {
      print("Error decoding Base64: $e");
    }
  }

  // Helper function to convert color name to Color object
  Color _getColorFromName(String colorName) {
    // Map color names to Color values
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      default:
        return Colors.grey; // Default color if no match
    }
  }

  // Function to get unique colors from stockData
  List<String> getUniqueColors() {
    Set<String> uniqueColors = {};
    for (var item in stockData) {
      uniqueColors.add(item['color']['colorName']);
    }
    return uniqueColors.toList();
  }

  // Function to get sizes and stock for a specific color
  List<Map<String, dynamic>> getSizesForColor(String colorName) {
    return stockData
        .where((item) => item['color']['colorName'] == colorName)
        .toList();
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: widget.product['productName']
            .toString()
            .text
            .color(darkFontGrey)
            .fontFamily(bold)
            .make(),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.favorite_outline)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (mainImage != null)
                      Image.memory(mainImage!,
                          width: double.infinity,
                          height: 350,
                          fit: BoxFit.cover),
                    10.heightBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (subImage1 != null)
                          Image.memory(subImage1!,
                                  width: 100, height: 100, fit: BoxFit.cover)
                              .box
                              .roundedSM
                              .make(),
                        10.widthBox,
                        if (subImage2 != null)
                          Image.memory(subImage2!,
                                  width: 100, height: 100, fit: BoxFit.cover)
                              .box
                              .roundedSM
                              .make(),
                      ],
                    ),
                    10.heightBox,
                    widget.product['productName']
                        .toString()
                        .text
                        .size(16)
                        .color(darkFontGrey)
                        .fontFamily(semibold)
                        .make(),
                    10.heightBox,
                    "Highlights: ${widget.product['productHighLights']}"
                        .text
                        .color(darkFontGrey)
                        .make(),
                    10.heightBox,
                    "Description: ${widget.product['productDescription']}"
                        .text
                        .color(darkFontGrey)
                        .make(),
                    10.heightBox,
                    "Brand: ${widget.product['brand']['brandName']}"
                        .text
                        .color(darkFontGrey)
                        .make(),
                    10.heightBox,
                    "Price: \₹ ${widget.product['productPrice']}"
                        .text
                        .color(redColor)
                        .fontFamily(bold)
                        .size(18)
                        .make(),
                    20.heightBox,
                    // Display Unique Colors and Sizes
                    if (stockData.isNotEmpty)
                      Column(
                        children: [
                          // Color Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: getUniqueColors().map((colorName) {
                              Color color = _getColorFromName(colorName);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // Toggle selected color
                                    if (selectedColor == colorName) {
                                      selectedColor = null; // Deselect
                                    } else {
                                      selectedColor = colorName; // Select
                                    }
                                    selectedSize = null; // Reset selected size
                                  });
                                },
                                child: Column(
                                  children: [
                                    // Color Circle
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: selectedColor == colorName
                                              ? Colors.black
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    // Color Name
                                    Text(
                                      colorName,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          10.heightBox,
                          // Show Sizes for Selected Color
                          if (selectedColor != null)
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children:
                                  getSizesForColor(selectedColor!).map((item) {
                                String sizeName = item['size']['sizeName'];
                                int stockCount = item['stockCount'];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      // Toggle selected size
                                      if (selectedSize == sizeName) {
                                        selectedSize = null; // Deselect
                                      } else {
                                        selectedSize = sizeName; // Select
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: selectedSize == sizeName
                                          ? Colors.blue
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: selectedSize == sizeName
                                            ? Colors.black
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          sizeName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: selectedSize == sizeName
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          stockCount > 0
                                              ? "Stock: $stockCount"
                                              : "No Stock",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: selectedSize == sizeName
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          Divider(),
                        ],
                      )
                    else
                      Text(
                        'No Stock Available!',
                        style: TextStyle(fontSize: 16),
                      ),
                    10.heightBox,
                    ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: List.generate(
                        itemDetailButtonList.length,
                        (index) => ListTile(
                          title: itemDetailButtonList[index]
                              .text
                              .fontFamily(semibold)
                              .color(darkFontGrey)
                              .make(),
                          trailing: const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ourButton(
              color: redColor,
              onPress: () async {
                if (selectedColor == null || selectedSize == null) {
                  showGlobalSnackBar('Please select color and size!');
                  return;
                }

                // Extract colorCode
                var selectedColorData = stockData.firstWhere(
                  (item) => item['color']['colorName'] == selectedColor,
                  orElse: () => <String, dynamic>{},
                );
                String colorCode =
                    selectedColorData['color']?['colorCode'] ?? '';

                // Extract sizeCode
                var selectedSizeData = stockData.firstWhere(
                  (item) => item['size']['sizeName'] == selectedSize,
                  orElse: () => <String, dynamic>{},
                );
                String sizeCode = selectedSizeData['size']?['sizeCode'] ?? '';

                if (colorCode.isEmpty || sizeCode.isEmpty) {
                  showGlobalSnackBar('Invalid selection. Please try again.');
                  return;
                }

                // Ensure productCode is available
                String productCode = widget.product['productCode'] ?? '';

                // ✅ Check if item already exists in cart
                var existingCartItem = cartItems.firstWhere(
                  (item) =>
                      item['product']['productCode'] == productCode &&
                      item['sizeCode'] == sizeCode &&
                      item['colorCode'] == colorCode,
                  orElse: () => <String, dynamic>{},
                );

                if (existingCartItem.isNotEmpty) {
                  // ✅ If item exists, update the count
                  int newCount = existingCartItem['count'] + 1;
                  Map<String, dynamic> updatedCartItem = {
                    "cartCode": existingCartItem['cartCode'],
                    "productCode": productCode,
                    "sizeCode": sizeCode,
                    "colorCode": colorCode,
                    "userCode": userCode,
                    "count": newCount,
                  };

                  await _cartService.updateCartItem(updatedCartItem);
                } else {
                  // ✅ If item does not exist, add a new one
                  Map<String, dynamic> newCartItem = {
                    "productCode": productCode,
                    "sizeCode": sizeCode,
                    "colorCode": colorCode,
                    "userCode": userCode,
                    "count": 1,
                  };

                  await _cartService.addCartItem(newCartItem);
                }

                // Refresh cart items after update
                fetchCartItems();
              },
              textColor: whiteColor,
              title: "Add to cart",
            ),
          )
        ],
      ),
    );
  }
}
