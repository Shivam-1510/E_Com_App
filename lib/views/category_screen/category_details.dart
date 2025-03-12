import 'dart:convert';
import 'dart:typed_data';
import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/services/Manage%20Products/productservice.dart';
import 'package:e_comapp/views/category_screen/category_item_details.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:get/get.dart';

class CategoryDetails extends StatefulWidget {
  final String? title;
  final String? selectedCategory; // New field

  const CategoryDetails(
      {Key? key, required this.title, required this.selectedCategory})
      : super(key: key);

  @override
  _CategoryDetailsState createState() => _CategoryDetailsState();
}

class _CategoryDetailsState extends State<CategoryDetails> {
  final ProductService _productService = ProductService();
  List<dynamic> products = [];
  List<dynamic> filteredProducts = []; // New list for filtered products

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final fetchedProducts = await _productService.fetchProducts();
    if (fetchedProducts != null) {
      setState(() {
        products = fetchedProducts;
        String category = widget.selectedCategory!.toLowerCase().trim();

        // Split category into individual words for broader matching
        List<String> categoryWords =
            category.split(RegExp(r'\s+')); // Splitting on spaces

        filteredProducts = products.where((product) {
          String productName =
              product['productName']?.toString().toLowerCase().trim() ?? '';
          String description =
              product['productDescription']?.toString().toLowerCase().trim() ??
                  '';
          String productCategory =
              product['productHighLights']?.toString().toLowerCase().trim() ??
                  '';
          String tags = product['tags']?.toString().toLowerCase().trim() ?? '';

          // Combine all searchable fields
          String combinedText =
              "$productName $description $productCategory $tags";

          // Check if at least one word from category exists in product details
          return categoryWords.any((word) => combinedText.contains(word));
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      Scaffold(
        appBar: AppBar(
          title: widget.title!.text.fontFamily(bold).white.make(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              20.heightBox,
              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          "No products available",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkFontGrey,
                          ),
                        ),
                      )
                    : GridView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: filteredProducts.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, mainAxisExtent: 250),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          Uint8List imageBytes =
                              base64Decode(product['firstImage']);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.memory(
                                imageBytes,
                                height: 150,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                              product['productName']
                                  .toString()
                                  .text
                                  .fontFamily(semibold)
                                  .color(darkFontGrey)
                                  .make(),
                            ],
                          )
                              .box
                              .color(const Color.fromARGB(255, 252, 234, 234))
                              .margin(const EdgeInsets.symmetric(horizontal: 4))
                              .roundedSM
                              .outerShadowSm
                              .padding(const EdgeInsets.all(12))
                              .make()
                              .onTap(() {
                            Get.to(() => ItemsDetails(product: product));
                          });
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
