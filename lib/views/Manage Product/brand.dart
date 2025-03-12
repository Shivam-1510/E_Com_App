import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/services/Manage%20Products/brandservice.dart';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:e_comapp/views/widgets_common/drawer.dart';

class Brand extends StatefulWidget {
  const Brand({super.key});
  @override
  State<Brand> createState() => _BrandState();
}

class _BrandState extends State<Brand> {
  final searchController = TextEditingController();
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController brandDetailsController = TextEditingController();
  final Brandservice _brandservice = Brandservice();
  bool isLoading = true;
  bool isActive = false;
  List<dynamic> _brands = [];
  List<dynamic> _filteredBrand = [];
  List<dynamic> brandItems = []; // list to store the branditems

  @override
  void initState() {
    super.initState();
    fetchBrand();
    searchController.addListener(() {
      filterBrands(searchController.text);
    });
  }

  Future<void> fetchBrand() async {
    final brands = await _brandservice.fetchBrand();
    if (brands != null) {
      setState(() {
        _brands = brands;
        _filteredBrand = brands;
        brandItems = _brands.map((brand) {
          return {
            "brandCode":
                brand["brandCode"].toString(), // Always convert to String
            "brandName": brand["brandName"],
          };
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterBrands(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBrand = _brands;
      } else {
        _filteredBrand = _brands.where((brand) {
          final brandName = brand["brandName"]?.toLowerCase() ?? "";
          final brandDetails = brand["brandDetails"]?.toLowerCase() ?? "";
          return brandName.contains(query.toLowerCase()) ||
              brandDetails.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      Scaffold(
        appBar: AppBar(
            title: Text(
              'Brand',
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
                          'Create New',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: bold,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () async {
                          brandNameController.clear;
                          brandDetailsController.clear;
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
                                              "Create Brand",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: 'bold'),
                                            ),
                                            SizedBox(height: 20),
                                            // brand name field
                                            TextField(
                                              controller: brandNameController,
                                              decoration: InputDecoration(
                                                labelText: "Brand Name",
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            TextField(
                                              controller:
                                                  brandDetailsController,
                                              decoration: InputDecoration(
                                                  labelText: "Brand Details",
                                                  border: OutlineInputBorder()),
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
                                                    final brandName =
                                                        brandNameController
                                                            .text;
                                                    final brandDetails =
                                                        brandDetailsController
                                                            .text;
                                                    if (brandName.isEmpty ||
                                                        brandDetails.isEmpty) {
                                                      showGlobalSnackBar(
                                                          'Brand Name & Brand Details are required!');
                                                    }
                                                    final result =
                                                        await _brandservice
                                                            .createBrand(
                                                                brandName,
                                                                brandDetails);
                                                    if (result != null) {
                                                      fetchBrand();
                                                      Navigator.pop(context);
                                                    } else {
                                                      showGlobalSnackBar(
                                                          'Failed to Create Brand!');
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
                                                )
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
                    // Card
                    isLoading
                        ? CircularProgressIndicator()
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'Brand ',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (_filteredBrand.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'No Brands found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                else
                                  ..._filteredBrand.map((brand) {
                                    return Card(
                                      elevation: 5,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Brand Name: ${brand["brandName"] ?? ""}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Brand Details: ${brand["brandDetails"] ?? ""}',
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: Colors.blue,
                                                  ),
                                                  onPressed: () {
                                                    final currentBrandName =
                                                        brand['brandName']
                                                                ?.toString() ??
                                                            '';
                                                    final currentBrandDetails =
                                                        brand['brandDetails']
                                                                ?.toString() ??
                                                            '';
                                                    String updatedBrandName =
                                                        currentBrandName;
                                                    String updatedBrandDetails =
                                                        currentBrandDetails;
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return StatefulBuilder(
                                                              builder: (context,
                                                                  setState) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  'Edit Brand'),
                                                              content:
                                                                  SingleChildScrollView(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    TextField(
                                                                      controller:
                                                                          TextEditingController(
                                                                              text: updatedBrandName),
                                                                      onChanged:
                                                                          (value) {
                                                                        updatedBrandName =
                                                                            value;
                                                                      },
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'Brand Name',
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            16),
                                                                    TextField(
                                                                      controller:
                                                                          TextEditingController(
                                                                              text: updatedBrandDetails),
                                                                      onChanged:
                                                                          (value) {
                                                                        updatedBrandDetails =
                                                                            value;
                                                                      },
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'Brand Details',
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(),
                                                                  child: Text(
                                                                      'Cancel'),
                                                                ),
                                                                ElevatedButton(
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    if (updatedBrandName
                                                                            .isEmpty ||
                                                                        updatedBrandDetails
                                                                            .isEmpty) {
                                                                      showGlobalSnackBar(
                                                                          'Please fill all fields');
                                                                      return;
                                                                    }
                                                                    await _brandservice
                                                                        .updateBrand(
                                                                      brand['brandCode']
                                                                              ?.toString() ??
                                                                          '',
                                                                      updatedBrandName,
                                                                      updatedBrandDetails,
                                                                    );
                                                                    fetchBrand();
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                    'Update',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          });
                                                        });
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: redColor,
                                                  ),
                                                  onPressed: () async {
                                                    final brandCode =
                                                        brand["brandCode"];
                                                    if (brandCode != null &&
                                                        brandCode.isNotEmpty) {
                                                      await _brandservice
                                                          .deleteBrand(
                                                              brandCode);
                                                      fetchBrand();
                                                    }
                                                  },
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              ],
                            ),
                          )
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
        ),
      ),
    );
  }
}
