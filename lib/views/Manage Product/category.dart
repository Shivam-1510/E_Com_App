import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/services/Manage%20Products/categoryservice.dart';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:e_comapp/views/widgets_common/drawer.dart';

class Category2 extends StatefulWidget {
  const Category2({super.key});
  @override
  State<Category2> createState() => _Category2State();
}

class _Category2State extends State<Category2> {
  final Categoryservice _categoryservice = Categoryservice();
  final searchController = TextEditingController();
  final TextEditingController categoryNameController = TextEditingController();
  bool isLoading = true;
  bool isActive = false;
  List<dynamic> _category = [];
  List<dynamic> _filteredCategory = [];
  List<dynamic> categoryItems = [];

  @override
  void initState() {
    super.initState();
    fetchCategory();
    searchController.addListener(() {
      filterCategory(searchController.text);
    });
  }

  Future<void> fetchCategory() async {
    final categories = await _categoryservice.fetchCategory();
    if (categories != null) {
      setState(() {
        _category = categories;
        _filteredCategory = categories;
        categoryItems = _category.map((category) {
          return {
            "categoryCode": category["categoryCode"].toString(),
            "categoryName": category["categoryName"],
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

  void filterCategory(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategory = _category;
      } else {
        _filteredCategory = _category.where((category) {
          final categoryName = category["categoryName"]?.toLowerCase() ?? "";
          return categoryName.contains(query.toLowerCase());
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
              'Category',
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Create New',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: bold,
                              fontSize: 14),
                        ),
                        onPressed: () async {
                          categoryNameController.clear();
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
                                      padding: EdgeInsets.all(16),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Create Category",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: bold),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            TextField(
                                              controller:
                                                  categoryNameController,
                                              decoration: InputDecoration(
                                                labelText: "Category Name",
                                                border: OutlineInputBorder(),
                                              ),
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
                                                      final categoryName =
                                                          categoryNameController
                                                              .text;
                                                      if (categoryName
                                                          .isEmpty) {
                                                        showGlobalSnackBar(
                                                            'Category Name is required!');
                                                      }
                                                      final result =
                                                          await _categoryservice
                                                              .createCategory(
                                                                  categoryName);
                                                      if (result != null) {
                                                        fetchCategory();
                                                        Navigator.pop(context);
                                                      } else {
                                                        showGlobalSnackBar(
                                                            'Failed to create Category!');
                                                      }
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                Colors.red),
                                                    child: Text(
                                                      'Save',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ))
                                              ],
                                            ),
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
                    // CARD
                    isLoading
                        ? CircularProgressIndicator()
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'Category',
                                    style: TextStyle(
                                        fontSize: 22, fontFamily: bold),
                                  ),
                                ),
                                if (_filteredCategory.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'No Categories found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                else
                                  ..._filteredCategory.map((category) {
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
                                              'Category Name: ${category["categoryName"] ?? ""}',
                                              style: TextStyle(
                                                fontFamily: bold,
                                                fontSize: 18,
                                              ),
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
                                                    final currentCategoryName =
                                                        category['categoryName']
                                                                ?.toString() ??
                                                            '';
                                                    String updatedCategoryName =
                                                        currentCategoryName;
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return StatefulBuilder(
                                                              builder: (context,
                                                                  setState) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  'Edit Category'),
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
                                                                              text: updatedCategoryName),
                                                                      onChanged:
                                                                          (value) {
                                                                        updatedCategoryName =
                                                                            value;
                                                                      },
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'Category Name',
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                      ),
                                                                    )
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
                                                                    style: ElevatedButton.styleFrom(
                                                                        backgroundColor:
                                                                            redColor),
                                                                    onPressed:
                                                                        () async {
                                                                      if (updatedCategoryName
                                                                          .isEmpty) {
                                                                        showGlobalSnackBar(
                                                                            'Please fill all fields');
                                                                        return;
                                                                      }
                                                                      await _categoryservice.updateCategory(
                                                                          category['categoryCode']?.toString() ??
                                                                              '',
                                                                          updatedCategoryName);
                                                                      fetchCategory();
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: Text(
                                                                      'Update',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ))
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
                                                    final categoryCode =
                                                        category[
                                                            'categoryCode'];
                                                    if (categoryCode != null &&
                                                        categoryCode
                                                            .isNotEmpty) {
                                                      await _categoryservice
                                                          .delteCategory(
                                                              categoryCode);
                                                      fetchCategory();
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
        ),
      ),
    );
  }
}
