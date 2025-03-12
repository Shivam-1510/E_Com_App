import 'dart:convert';
import 'dart:io';
import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/services/Manage%20Products/brandservice.dart';
import 'package:e_comapp/services/Manage%20Products/categoryservice.dart';
import 'package:e_comapp/services/Manage%20Products/colorservice.dart';
import 'package:e_comapp/services/Manage%20Products/productservice.dart';
import 'package:e_comapp/services/Manage%20Products/sizeservice.dart';
import 'package:e_comapp/services/Manage%20Products/stockservice.dart';
import 'package:e_comapp/services/getloginuesrrole.dart';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:e_comapp/views/widgets_common/drawer.dart';
import 'package:flutter/foundation.dart';

import 'package:image_picker/image_picker.dart';

class Products extends StatefulWidget {
  const Products({super.key});
  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final Brandservice _brandservice = Brandservice();
  final Categoryservice _categoryservice = Categoryservice();
  final ProductService _productservice = ProductService();
  final UserRoleService _userRoleService = UserRoleService();
  final StockService _stockService = StockService();

  List<Map<String, dynamic>> stockData = [];

  final Colorservice _colorService = Colorservice();
  final Sizeservice _sizeService = Sizeservice();
  List<dynamic> products = [];
  bool isLoading = true;
  final searchController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productDescriptionController =
      TextEditingController();
  final TextEditingController productHighlightsController =
      TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController stockCountController = TextEditingController();
  final TextEditingController productStatusController = TextEditingController();
  final TextEditingController productBrandCodeController =
      TextEditingController();
  final TextEditingController productCategoryCodeController =
      TextEditingController();
  List<Map<String, dynamic>> brands = [];
  String? selectedBrandCode;
  bool isLoadingBrands = true; // For showing a loading indicator
  List<Map<String, dynamic>> categories = [];
  String? selectedCategoryCode;
  bool isLoadingCategories = true; // For showing a loading indicator
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = []; // Store selected images
  List<String> base64Images = []; // Store Base64 encoded images
  int? userRoleLevel;
  dynamic userCode;

  // 📌 Function to Pick Images
  Future<void> pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.length == 3) {
      setState(() {
        selectedImages = pickedFiles;
        convertImagesToBase64();
        showGlobalSnackBar('Images selected!');
      });
    } else {
      showGlobalSnackBar("Please select exactly 3 images.");
    }
  }

  // 📌 Convert Images to Base64
  // 📌 Convert Images to Base64 (Web & Mobile Compatible)
  Future<void> convertImagesToBase64() async {
    base64Images.clear();
    for (XFile image in selectedImages) {
      if (kIsWeb) {
        // ✅ Convert to Base64 for Web
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        base64Images.add(base64String);
      } else {
        // ✅ Convert to Base64 for Mobile (Android/iOS)
        File file = File(image.path);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        base64Images.add(base64String);
      }
    }
  }

  Future<List<String>> pickImages2() async {
    List<String> base64Images = [];
    final ImagePicker _picker = ImagePicker();

    for (int i = 0; i < 3; i++) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        base64Images.add(base64Encode(bytes));
      } else {
        base64Images.add("");
      }
    }

    return base64Images;
  }

  Future<void> loadCategories() async {
    final fetchedCategories = await _categoryservice.fetchCategory();
    if (fetchedCategories != null) {
      setState(() {
        categories = fetchedCategories;
        isLoadingCategories = false;
      });
    } else {
      setState(() {
        isLoadingCategories = false; // Stop loading if the fetch fails
      });
      showGlobalSnackBar("Failed to load categories.");
    }
  }

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

  Future<void> loadBrands() async {
    final fetchedBrands = await _brandservice.fetchBrand();
    if (fetchedBrands != null) {
      setState(() {
        brands = fetchedBrands;
        isLoadingBrands = false;
      });
    } else {
      setState(() {
        isLoadingBrands = false; // Stop loading if the fetch fails
      });
      showGlobalSnackBar("Failed to load brands.");
    }
  }

  Future<void> fetchProd() async {
    final fetchedProducts = await _productservice.fetchProducts();
    if (fetchedProducts != null) {
      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadBrands();
    loadCategories();
    fetchLoggedInUserDetails();
    fetchProd();
  }

  void showUpdateImageDialog(
      BuildContext context, String productCode, List<String> currentImages) {
    List<String> base64Images =
        List.from(currentImages); // Copy current images for editing

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Update Product Images",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (int i = 0; i < 3; i++)
                              Column(
                                children: [
                                  base64Images[i].isEmpty
                                      ? Icon(Icons.image, size: 100)
                                      : Image.memory(
                                          base64Decode(base64Images[i]),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final XFile? image =
                                          await _picker.pickImage(
                                              source: ImageSource.gallery);
                                      if (image != null) {
                                        final bytes = await image.readAsBytes();
                                        final base64String =
                                            base64Encode(bytes);
                                        setState(() {
                                          base64Images[i] = base64String;
                                        });
                                      }
                                    },
                                    child: Text("Edit Image ${i + 1}"),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (base64Images[0].isEmpty ||
                                  base64Images[1].isEmpty ||
                                  base64Images[2].isEmpty) {
                                showGlobalSnackBar('Please select 3 images!');
                                return;
                              }

                              await _productservice.updateProductImages(
                                productCode,
                                base64Images[0], // ✅ Image
                                base64Images[1], // ✅ Image
                                base64Images[2], // ✅ Image
                              );

                              Navigator.pop(context);
                              fetchProd();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text(
                              'Update',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(Scaffold(
        appBar: AppBar(
            title: Text(
              'Product',
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: IconThemeData(color: Colors.white)),
        drawer: CustomDrawer(),
        body: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: context.screenHeight * 0.02),
                applogoWidget(),
                20.heightBox,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Field
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.topRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: redColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Add Product',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: bold,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                    builder: (context, setState) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Add Product",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: 'bold'),
                                            ),
                                            SizedBox(height: 20),
                                            TextField(
                                              controller: productNameController,
                                              decoration: InputDecoration(
                                                labelText: "Product Name",
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            TextField(
                                              controller:
                                                  productDescriptionController,
                                              decoration: InputDecoration(
                                                  labelText: "Product Details",
                                                  border: OutlineInputBorder()),
                                            ),
                                            SizedBox(height: 20),
                                            TextField(
                                              controller:
                                                  productHighlightsController,
                                              decoration: InputDecoration(
                                                  labelText:
                                                      "Product Highlights",
                                                  border: OutlineInputBorder()),
                                            ),
                                            SizedBox(height: 20),
                                            TextField(
                                              controller:
                                                  productPriceController,
                                              decoration: InputDecoration(
                                                  labelText: "Product Price",
                                                  border: OutlineInputBorder()),
                                            ),
                                            SizedBox(height: 20),
                                            TextField(
                                              controller: stockCountController,
                                              decoration: InputDecoration(
                                                  labelText: "Product Stock",
                                                  border: OutlineInputBorder()),
                                            ),

                                            SizedBox(height: 20),
                                            // TextField(
                                            //   controller:
                                            //       productStatusController,
                                            //   decoration: InputDecoration(
                                            //       labelText: "Product Status",
                                            //       border: OutlineInputBorder()),
                                            // ),
                                            // SizedBox(height: 20),
                                            Flexible(
                                              child: isLoadingBrands
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator()) // Show loader while fetching
                                                  : DropdownButtonFormField<
                                                      String>(
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: "Brand Name",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                      hint: const Text(
                                                          "Select Brand"), // Default hint
                                                      value:
                                                          selectedBrandCode, // Currently selected brandCode
                                                      items:
                                                          brands.map((brand) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: brand[
                                                              'brandCode'], // Use brandCode as the value
                                                          child: Text(brand[
                                                                  'brandName'] ??
                                                              "Unknown"), // Display brandName
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          (String? brandCode) {
                                                        setState(() {
                                                          selectedBrandCode =
                                                              brandCode; // Update the selected brand code
                                                          productBrandCodeController
                                                                  .text =
                                                              brandCode ??
                                                                  ""; // Keep the text field updated
                                                        });
                                                      },
                                                      isExpanded: true,
                                                    ),
                                            ),
                                            SizedBox(height: 20),
                                            Flexible(
                                              child: isLoadingCategories
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator()) // Show loader while fetching
                                                  : DropdownButtonFormField<
                                                      String>(
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            "Category Name",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                      hint: const Text(
                                                          "Select Category"), // Default hint
                                                      value:
                                                          selectedCategoryCode, // Currently selected categoryCode
                                                      items: categories
                                                          .map((category) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: category[
                                                              'categoryCode'], // Use categoryCode as the value
                                                          child: Text(category[
                                                                  'categoryName'] ??
                                                              "Unknown"), // Display categoryName
                                                        );
                                                      }).toList(),
                                                      onChanged: (String?
                                                          categoryCode) {
                                                        setState(() {
                                                          selectedCategoryCode =
                                                              categoryCode; // Update selected category
                                                          productCategoryCodeController
                                                                  .text =
                                                              categoryCode ??
                                                                  ""; // Keep the text field updated
                                                        });
                                                      },
                                                      isExpanded: true,
                                                    ),
                                            ),
                                            SizedBox(height: 10),
                                            ElevatedButton(
                                              onPressed: pickImages,
                                              child: Text("Select 3 Images"),
                                            ),
                                            SizedBox(height: 20),

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        color: redColor),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    final productName =
                                                        productNameController
                                                            .text;
                                                    final productDescription =
                                                        productDescriptionController
                                                            .text;
                                                    final productHighLights =
                                                        productHighlightsController
                                                            .text;
                                                    final productPrice =
                                                        double.tryParse(
                                                                productPriceController
                                                                    .text) ??
                                                            0.0;
                                                    final stockCount = int.tryParse(
                                                            stockCountController
                                                                .text) ??
                                                        0;
                                                    final brandCode =
                                                        selectedBrandCode;
                                                    final categoryCode =
                                                        selectedCategoryCode;

                                                    if (productName.isEmpty ||
                                                        productDescription
                                                            .isEmpty ||
                                                        productHighLights
                                                            .isEmpty ||
                                                        productPrice <=
                                                            0.0 || // Ensure price is valid
                                                        stockCount <
                                                            0 || // Ensure stock is valid
                                                        brandCode == null ||
                                                        categoryCode == null ||
                                                        userCode == null ||
                                                        base64Images.length !=
                                                            3) {
                                                      showGlobalSnackBar(
                                                          'All the Fields are required!');
                                                      return;
                                                    }

                                                    final firstImage =
                                                        base64Images[0];
                                                    final secondImage =
                                                        base64Images[1];
                                                    final thirdImage =
                                                        base64Images[2];

                                                    final result =
                                                        await _productservice
                                                            .createProduct(
                                                      productName,
                                                      productDescription,
                                                      productHighLights,
                                                      productPrice, // Now it's a double
                                                      stockCount, // Now it's an integer
                                                      brandCode,
                                                      categoryCode,
                                                      firstImage,
                                                      secondImage,
                                                      thirdImage,
                                                      userCode,
                                                    );
                                                    if (result != null) {
                                                      fetchProd();
                                                      Navigator.pop(context);
                                                    } else {
                                                      showGlobalSnackBar(
                                                          'Failed to Add Product!');
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red),
                                                  child: Text(
                                                    'Save',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                              });
                        },
                      ),
                    ),

                    SizedBox(height: 10),
                    isLoading
                        ? CircularProgressIndicator()
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                Text(
                                  "Product List",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    final String base64Image =
                                        product['firstImage'] ?? "";

                                    Widget productImage;
                                    if (base64Image.isNotEmpty) {
                                      try {
                                        final Uint8List imageBytes =
                                            base64Decode(base64Image);
                                        productImage = Image.memory(
                                          imageBytes,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        );
                                      } catch (e) {
                                        productImage =
                                            Icon(Icons.broken_image, size: 100);
                                      }
                                    } else {
                                      productImage = Icon(
                                          Icons.image_not_supported,
                                          size: 100);
                                    }

                                    return Card(
                                      margin: EdgeInsets.all(7),
                                      elevation: 4,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            height: 120,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: productImage,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product['productName'] ??
                                                        "No Name",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    "Brand: ${product['brand']['brandName'] ?? "N/A"}",
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                  Text(
                                                    "Price: ₹ ${product['productPrice'] ?? "N/A"}",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.visibility,
                                                              color:
                                                                  Colors.green),
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return StatefulBuilder(
                                                                  builder: (context,
                                                                      StateSetter
                                                                          setDialogState) {
                                                                    final String
                                                                        firstImageBase64 =
                                                                        product['firstImage'] ??
                                                                            "";
                                                                    final String
                                                                        secondImageBase64 =
                                                                        product['secondImage'] ??
                                                                            "";
                                                                    final String
                                                                        thirdImageBase64 =
                                                                        product['thirdImage'] ??
                                                                            "";

                                                                    bool
                                                                        tempStatus =
                                                                        product['productStatus'] ==
                                                                            true; // ✅ Ensure bool value

                                                                    Widget getImageWidget(
                                                                        String
                                                                            base64String) {
                                                                      if (base64String
                                                                          .isEmpty)
                                                                        return Icon(
                                                                            Icons
                                                                                .image_not_supported,
                                                                            size:
                                                                                100);
                                                                      try {
                                                                        final Uint8List
                                                                            imageBytes =
                                                                            base64Decode(base64String);
                                                                        return Image.memory(
                                                                            imageBytes,
                                                                            width:
                                                                                100,
                                                                            height:
                                                                                100,
                                                                            fit:
                                                                                BoxFit.cover);
                                                                      } catch (e) {
                                                                        return Icon(
                                                                            Icons
                                                                                .broken_image,
                                                                            size:
                                                                                100);
                                                                      }
                                                                    }

                                                                    return Dialog(
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(16),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            16),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              "Product Status Update",
                                                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                            ),
                                                                            SizedBox(height: 20),

                                                                            // **Product Images Row**
                                                                            SingleChildScrollView(
                                                                              scrollDirection: Axis.horizontal,
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                children: [
                                                                                  getImageWidget(firstImageBase64),
                                                                                  SizedBox(width: 10),
                                                                                  getImageWidget(secondImageBase64),
                                                                                  SizedBox(width: 10),
                                                                                  getImageWidget(thirdImageBase64),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: 20),
                                                                            Text("Description: ${product['productDescription'] ?? "N/A"}"),
                                                                            Text("Highlights: ${product['productHighLights'] ?? "N/A"}"),

                                                                            Text("Category: ${product['category']['categoryName'] ?? "N/A"}"),
                                                                            Text("Stock: ${product['stockCount'] ?? "N/A"}"),
                                                                            SizedBox(height: 10),
                                                                            // **Status Toggle**
                                                                            Text("Product Status",
                                                                                style: TextStyle(fontSize: 18)),
                                                                            Switch(
                                                                              value: product['productStatus'] == true, // ✅ Ensure it's bool
                                                                              onChanged: (value) {
                                                                                setDialogState(() {
                                                                                  product['productStatus'] = value; // ✅ Directly updating product['productStatus']
                                                                                });
                                                                              },
                                                                              activeColor: Colors.green,
                                                                              inactiveTrackColor: Colors.grey[300],
                                                                              inactiveThumbColor: Colors.grey,
                                                                            ),

                                                                            // **Action Buttons**
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                TextButton(
                                                                                  onPressed: () => Navigator.pop(context),
                                                                                  child: Text('Close', style: TextStyle(color: Colors.red)),
                                                                                ),
                                                                                ElevatedButton(
                                                                                  onPressed: () async {
                                                                                    bool result = await _productservice.toggleProductStatus(product['productCode']);

                                                                                    if (result) {
                                                                                      setState(() {
                                                                                        product['productStatus'] = tempStatus; // ✅ Correctly update main UI
                                                                                      });

                                                                                      showGlobalSnackBar("✅ Status updated successfully!");
                                                                                      Navigator.pop(context);
                                                                                    } else {
                                                                                      showGlobalSnackBar("❌ Failed to update status.");
                                                                                    }
                                                                                  },
                                                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                                                  child: Text(
                                                                                    "Save",
                                                                                    style: TextStyle(color: Colors.white),
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.edit,
                                                            color: Colors.blue,
                                                          ),
                                                          onPressed: () {
                                                            final currentProductName =
                                                                product['productName']
                                                                        ?.toString() ??
                                                                    '';
                                                            final currentProductDesc =
                                                                product['productDescription']
                                                                        ?.toString() ??
                                                                    '';
                                                            final currentProductHigh =
                                                                product['productHighLights']
                                                                        ?.toString() ??
                                                                    '';
                                                            final currentBrandCode =
                                                                product['brandCode']
                                                                        ?.toString() ??
                                                                    '';
                                                            final currentCategoryCode =
                                                                product['categoryCode']
                                                                        ?.toString() ??
                                                                    '';
                                                            final currentProductPrice =
                                                                product['productPrice']
                                                                        ?.toString() ??
                                                                    '';

                                                            String
                                                                updatedProductName =
                                                                currentProductName;
                                                            String
                                                                updatedProductDesc =
                                                                currentProductDesc;
                                                            String
                                                                updatedProductHigh =
                                                                currentProductHigh;
                                                            String?
                                                                updatedBrandCode =
                                                                currentBrandCode;
                                                            String?
                                                                updatedCategoryCode =
                                                                currentCategoryCode;
                                                            String?
                                                                updatedProductPrice =
                                                                currentProductPrice;

                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return StatefulBuilder(
                                                                      builder:
                                                                          (context,
                                                                              setState) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          'Edit Product Details'),
                                                                      content:
                                                                          SingleChildScrollView(
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            TextField(
                                                                              controller: TextEditingController(text: updatedProductName),
                                                                              onChanged: (value) {
                                                                                updatedProductName = value;
                                                                              },
                                                                              decoration: InputDecoration(
                                                                                labelText: 'Product Name',
                                                                                border: OutlineInputBorder(),
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: 16),
                                                                            TextField(
                                                                              controller: TextEditingController(text: updatedProductDesc),
                                                                              onChanged: (value) {
                                                                                updatedProductDesc = value;
                                                                              },
                                                                              decoration: InputDecoration(
                                                                                labelText: 'Product Description',
                                                                                border: OutlineInputBorder(),
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: 16),
                                                                            TextField(
                                                                              controller: TextEditingController(text: updatedProductHigh),
                                                                              onChanged: (value) {
                                                                                updatedProductHigh = value;
                                                                              },
                                                                              decoration: InputDecoration(
                                                                                labelText: 'Product Highlights',
                                                                                border: OutlineInputBorder(),
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: 16),
                                                                            TextField(
                                                                              controller: TextEditingController(text: updatedProductPrice),
                                                                              onChanged: (value) {
                                                                                updatedProductPrice = value;
                                                                              },
                                                                              decoration: InputDecoration(
                                                                                labelText: 'Product Price',
                                                                                border: OutlineInputBorder(),
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: 16),
                                                                            Flexible(
                                                                              child: isLoadingBrands
                                                                                  ? const Center(child: CircularProgressIndicator())
                                                                                  : DropdownButtonFormField<String>(
                                                                                      decoration: InputDecoration(
                                                                                        labelText: "Brand Name",
                                                                                        border: OutlineInputBorder(),
                                                                                      ),
                                                                                      value: updatedBrandCode,
                                                                                      items: brands.map((brand) {
                                                                                        return DropdownMenuItem<String>(
                                                                                          value: brand['brandCode'],
                                                                                          child: Text(brand['brandName'] ?? "Unknown"),
                                                                                        );
                                                                                      }).toList(),
                                                                                      onChanged: (newValue) {
                                                                                        setState(() {
                                                                                          updatedBrandCode = newValue;
                                                                                        });
                                                                                      },
                                                                                      isExpanded: true,
                                                                                    ),
                                                                            ),
                                                                            SizedBox(height: 16),
                                                                            Flexible(
                                                                              child: isLoadingCategories
                                                                                  ? const Center(child: CircularProgressIndicator()) // Show loader while fetching
                                                                                  : DropdownButtonFormField<String>(
                                                                                      decoration: InputDecoration(
                                                                                        labelText: "Category Name",
                                                                                        border: OutlineInputBorder(),
                                                                                      ),

                                                                                      value: updatedCategoryCode, // Currently selected categoryCode
                                                                                      items: categories.map((category) {
                                                                                        return DropdownMenuItem<String>(
                                                                                          value: category['categoryCode'], // Use categoryCode as the value
                                                                                          child: Text(category['categoryName'] ?? "Unknown"), // Display categoryName
                                                                                        );
                                                                                      }).toList(),
                                                                                      onChanged: (newValue) {
                                                                                        setState(() {
                                                                                          updatedCategoryCode = newValue;
                                                                                        });
                                                                                      },
                                                                                      isExpanded: true,
                                                                                    ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      actions: [
                                                                        TextButton(
                                                                          child:
                                                                              Text(
                                                                            'Cancel',
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        ),
                                                                        ElevatedButton(
                                                                            style: ElevatedButton
                                                                                .styleFrom(
                                                                              backgroundColor: Colors.red,
                                                                            ),
                                                                            onPressed:
                                                                                () async {
                                                                              // Ensure productPrice is converted to double
                                                                              double parsedPrice = double.tryParse(updatedProductPrice ?? '0') ?? 0.0;

                                                                              // Ensure brandCode and categoryCode are not null
                                                                              String finalBrandCode = updatedBrandCode ?? '';
                                                                              String finalCategoryCode = updatedCategoryCode ?? '';

                                                                              // Get the current product's images
                                                                              String firstImage = product['firstImage'] ?? '';
                                                                              String secondImage = product['secondImage'] ?? '';
                                                                              String thirdImage = product['thirdImage'] ?? '';

                                                                              await _productservice.updateProduct(
                                                                                product['productCode']?.toString() ?? '',
                                                                                updatedProductName,
                                                                                updatedProductDesc,
                                                                                updatedProductHigh,
                                                                                parsedPrice,
                                                                                finalBrandCode,
                                                                                finalCategoryCode,
                                                                                userCode,
                                                                                firstImage, // Pass first image
                                                                                secondImage, // Pass second image
                                                                                thirdImage, // Pass third image
                                                                              );
                                                                              fetchProd();
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child:
                                                                                Text(
                                                                              'Update',
                                                                              style: TextStyle(color: Colors.white),
                                                                            ))
                                                                      ],
                                                                    );
                                                                  });
                                                                });
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon: Icon(Icons
                                                              .image_outlined),
                                                          onPressed: () {
                                                            // Pass the current images of the product to the dialog
                                                            showUpdateImageDialog(
                                                              context,
                                                              product[
                                                                  'productCode'],
                                                              [
                                                                product['firstImage'] ??
                                                                    "",
                                                                product['secondImage'] ??
                                                                    "",
                                                                product['thirdImage'] ??
                                                                    "",
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                              Icons.color_lens),
                                                          onPressed: () {
                                                            // 🔹 State Variables

                                                            List<dynamic>
                                                                colors = [];
                                                            List<dynamic>
                                                                sizes = [];

                                                            // 🔹 Fetch Stock Data
                                                            getStock(product[
                                                                    'productCode'])
                                                                .then((_) {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return StatefulBuilder(
                                                                    builder:
                                                                        (context,
                                                                            setState) {
                                                                      // 🔹 Fetch Colors & Sizes (Only Once)
                                                                      if (colors
                                                                              .isEmpty ||
                                                                          sizes
                                                                              .isEmpty) {
                                                                        _colorService
                                                                            .fetchColor()
                                                                            .then((data) {
                                                                          if (data !=
                                                                              null) {
                                                                            setState(() {
                                                                              colors = data;
                                                                            });
                                                                          }
                                                                        });

                                                                        _sizeService
                                                                            .fetchSize()
                                                                            .then((data) {
                                                                          if (data !=
                                                                              null) {
                                                                            setState(() {
                                                                              sizes = data;
                                                                            });
                                                                          }
                                                                        });
                                                                      }

                                                                      return Dialog(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(16),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              16),
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                // 🔹 Stock Count Display
                                                                                Text(
                                                                                  "Stock Count Display",
                                                                                  style: TextStyle(
                                                                                    fontSize: 18,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 10),
                                                                                stockData.isNotEmpty
                                                                                    ? Column(
                                                                                        children: stockData.map((item) {
                                                                                          return Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text(
                                                                                                "Stock: ${item['stockCount'].toString()}",
                                                                                                style: TextStyle(fontSize: 16),
                                                                                              ),
                                                                                              Text(
                                                                                                "Color: ${item['color']['colorName']}",
                                                                                                style: TextStyle(fontSize: 16),
                                                                                              ),
                                                                                              Text(
                                                                                                "Size: ${item['size']['sizeName']}",
                                                                                                style: TextStyle(fontSize: 16),
                                                                                              ),
                                                                                              Align(
                                                                                                alignment: Alignment.topRight,
                                                                                                child: IconButton(
                                                                                                  onPressed: () {
                                                                                                    showDialog(
                                                                                                      context: context,
                                                                                                      builder: (context) {
                                                                                                        // 🔸 Get stock details for this item
                                                                                                        String stockCode = item['stockCode'];
                                                                                                        TextEditingController updatedStockCountController = TextEditingController(
                                                                                                          text: item['stockCount'].toString(),
                                                                                                        );

                                                                                                        return AlertDialog(
                                                                                                          shape: RoundedRectangleBorder(
                                                                                                            borderRadius: BorderRadius.circular(16),
                                                                                                          ),
                                                                                                          content: StatefulBuilder(
                                                                                                            builder: (context, setState) {
                                                                                                              return SingleChildScrollView(
                                                                                                                child: Column(
                                                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                                                  children: [
                                                                                                                    SizedBox(height: 10),

                                                                                                                    // 🔹 Stock Count Input (Pre-filled)
                                                                                                                    TextField(
                                                                                                                      controller: updatedStockCountController,
                                                                                                                      keyboardType: TextInputType.number,
                                                                                                                      decoration: InputDecoration(
                                                                                                                        labelText: "Enter Stock Count",
                                                                                                                        border: OutlineInputBorder(),
                                                                                                                      ),
                                                                                                                    ),

                                                                                                                    SizedBox(height: 20),
                                                                                                                    ElevatedButton(
                                                                                                                      style: ElevatedButton.styleFrom(
                                                                                                                        backgroundColor: Colors.red,
                                                                                                                      ),
                                                                                                                      onPressed: () async {
                                                                                                                        int stockCount = int.tryParse(updatedStockCountController.text) ?? 0;
                                                                                                                        if (stockCount <= 0) {
                                                                                                                          showGlobalSnackBar("Please enter valid stock count!");
                                                                                                                          return;
                                                                                                                        }

                                                                                                                        bool success = await StockService().updateStock(
                                                                                                                          stockCode,
                                                                                                                          stockCount,
                                                                                                                        );

                                                                                                                        if (success) {
                                                                                                                          await getStock(product['productCode']);
                                                                                                                          setState(() {
                                                                                                                            stockData = stockData;
                                                                                                                          });
                                                                                                                          Navigator.pop(context);
                                                                                                                        }
                                                                                                                      },
                                                                                                                      child: Text(
                                                                                                                        "Update Stock",
                                                                                                                        style: TextStyle(color: Colors.white),
                                                                                                                      ),
                                                                                                                    ),

                                                                                                                    SizedBox(height: 10),

                                                                                                                    // 🔹 Close Button
                                                                                                                    TextButton(
                                                                                                                      onPressed: () => Navigator.pop(context),
                                                                                                                      child: Text(
                                                                                                                        'Close',
                                                                                                                        style: TextStyle(color: Colors.red),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ],
                                                                                                                ),
                                                                                                              );
                                                                                                            },
                                                                                                          ),
                                                                                                        );
                                                                                                      },
                                                                                                    );
                                                                                                  },
                                                                                                  icon: Icon(
                                                                                                    Icons.edit,
                                                                                                    color: Colors.blue,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Divider(),
                                                                                            ],
                                                                                          );
                                                                                        }).toList(),
                                                                                      )
                                                                                    : Text('No Stock found, Please add!'),

                                                                                SizedBox(height: 20),

                                                                                // 🔹 Size Dropdown
                                                                                // 🔹 Add Stock Button
                                                                                ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.red,
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder: (context) {
                                                                                        String? selectedSizeCode;
                                                                                        String? selectedColorCode;
                                                                                        TextEditingController stockCountController = TextEditingController();

                                                                                        return AlertDialog(
                                                                                          shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(16),
                                                                                          ),
                                                                                          content: StatefulBuilder(
                                                                                            builder: (context, setState) {
                                                                                              return SingleChildScrollView(
                                                                                                child: Column(
                                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                                  children: [
                                                                                                    // 🔹 Size Dropdown
                                                                                                    DropdownButton<String>(
                                                                                                      hint: Text("Select Size"),
                                                                                                      value: selectedSizeCode,
                                                                                                      items: sizes.map((size) {
                                                                                                        return DropdownMenuItem<String>(
                                                                                                          value: size['sizeCode'],
                                                                                                          child: Text(size['sizeName'] ?? "Unknown"),
                                                                                                        );
                                                                                                      }).toList(),
                                                                                                      onChanged: (String? newValue) {
                                                                                                        setState(() {
                                                                                                          selectedSizeCode = newValue;
                                                                                                        });
                                                                                                      },
                                                                                                      isExpanded: true,
                                                                                                    ),

                                                                                                    SizedBox(height: 10),

                                                                                                    // 🔹 Color Dropdown
                                                                                                    DropdownButton<String>(
                                                                                                      hint: Text("Select Color"),
                                                                                                      value: selectedColorCode,
                                                                                                      items: colors.map((color) {
                                                                                                        return DropdownMenuItem<String>(
                                                                                                          value: color['colorCode'],
                                                                                                          child: Text(color['colorName'] ?? "Unknown"),
                                                                                                        );
                                                                                                      }).toList(),
                                                                                                      onChanged: (String? newValue) {
                                                                                                        setState(() {
                                                                                                          selectedColorCode = newValue;
                                                                                                        });
                                                                                                      },
                                                                                                      isExpanded: true,
                                                                                                    ),

                                                                                                    SizedBox(height: 10),

                                                                                                    // 🔹 Stock Count Input
                                                                                                    TextField(
                                                                                                      controller: stockCountController,
                                                                                                      keyboardType: TextInputType.number,
                                                                                                      decoration: InputDecoration(
                                                                                                        labelText: "Enter Stock Count",
                                                                                                        border: OutlineInputBorder(),
                                                                                                      ),
                                                                                                    ),

                                                                                                    SizedBox(height: 20),

                                                                                                    ElevatedButton(
                                                                                                      style: ElevatedButton.styleFrom(
                                                                                                        backgroundColor: Colors.red,
                                                                                                      ),
                                                                                                      onPressed: () async {
                                                                                                        int stockCount = int.tryParse(stockCountController.text) ?? 0;
                                                                                                        if (selectedSizeCode == null || selectedColorCode == null || stockCount <= 0) {
                                                                                                          showGlobalSnackBar("Please enter valid data!");
                                                                                                          return;
                                                                                                        }

                                                                                                        bool success = await StockService().createStock(
                                                                                                          product['productCode'],
                                                                                                          selectedSizeCode!,
                                                                                                          selectedColorCode!,
                                                                                                          stockCount,
                                                                                                        );

                                                                                                        if (success) {
                                                                                                          Navigator.pop(context);
                                                                                                          await getStock(product['productCode']);
                                                                                                          setState(() {
                                                                                                            stockData = stockData;
                                                                                                          });
                                                                                                        }
                                                                                                      },
                                                                                                      child: Text(
                                                                                                        "Add Stock",
                                                                                                        style: TextStyle(color: Colors.white),
                                                                                                      ),
                                                                                                    ),

                                                                                                    SizedBox(height: 10),

                                                                                                    // 🔹 Close Button
                                                                                                    TextButton(
                                                                                                      onPressed: () => Navigator.pop(context),
                                                                                                      child: Text(
                                                                                                        'Close',
                                                                                                        style: TextStyle(color: Colors.red),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    );
                                                                                  },
                                                                                  child: Text(
                                                                                    "Add Stock",
                                                                                    style: TextStyle(color: Colors.white),
                                                                                  ),
                                                                                ),

                                                                                // 🔹 Update Stock Button (Placeholder)

                                                                                SizedBox(height: 10),

                                                                                // 🔹 Close Button
                                                                                TextButton(
                                                                                  onPressed: () => Navigator.pop(context),
                                                                                  child: Text(
                                                                                    'Close',
                                                                                    style: TextStyle(color: Colors.red),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              );
                                                            });
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                  ],
                )
                    .box
                    .white
                    .rounded
                    .padding(const EdgeInsets.all(16))
                    .width(context.screenWidth - 30)
                    .shadowSm
                    .make(),
              ],
            ),
          ),
        )));
  }
}
