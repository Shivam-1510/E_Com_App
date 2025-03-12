import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/services/Manage%20Products/sizeservice.dart';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:e_comapp/views/widgets_common/drawer.dart';
import 'package:flutter/material.dart';

class Size2 extends StatefulWidget {
  const Size2({super.key});
  @override
  State<Size2> createState() => _Size2State();
}

class _Size2State extends State<Size2> {
  final searchController = TextEditingController();
  final TextEditingController sizeNameController = TextEditingController();
  final TextEditingController sizeShortNameController = TextEditingController();
  final Sizeservice _sizeservice = Sizeservice();
  bool isLoading = true;
  bool isActive = false;
  List<dynamic> _size = [];
  List<dynamic> _filteredSize = [];
  List<dynamic> sizeItems = [];

  void initState() {
    super.initState();
    fetchSize();
    searchController.addListener(() {
      filterSize(searchController.text);
    });
  }

  Future<void> fetchSize() async {
    final size = await _sizeservice.fetchSize();
    if (size != null) {
      setState(() {
        _size = size;
        _filteredSize = size;
        sizeItems = _size.map((size) {
          return {
            "sizeCode": size["sizeCode"].toString(), // Always convert to String
            "sizeName": size["sizeName"],
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

  void filterSize(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSize = _size;
      } else {
        _filteredSize = _size.where((size) {
          final sizeName = size["sizeName"]?.toLowerCase() ?? "";
          final sizeShortName = size["sizeShortName"]?.toLowerCase() ?? "";
          return sizeName.contains(query.toLowerCase()) ||
              sizeShortName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(Scaffold(
      appBar: AppBar(
          title: Text(
            'Size',
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
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            fontSize: 14),
                      ),
                      onPressed: () async {
                        sizeNameController.clear();
                        sizeShortNameController.clear();
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
                                            'Create Size',
                                            style: TextStyle(
                                              fontFamily: bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          // Size name field
                                          TextField(
                                            controller: sizeNameController,
                                            decoration: InputDecoration(
                                              labelText: "Size ",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          TextField(
                                            controller: sizeShortNameController,
                                            decoration: InputDecoration(
                                                labelText: "Size Short Form",
                                                border: OutlineInputBorder()),
                                          ),
                                          SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    color: redColor,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  final sizeName =
                                                      sizeNameController.text;
                                                  final sizeShortName =
                                                      sizeShortNameController
                                                          .text;
                                                  if (sizeName.isEmpty ||
                                                      sizeShortName.isEmpty) {
                                                    showGlobalSnackBar(
                                                        'Size & Size Short Name is required!');
                                                  }
                                                  final result =
                                                      await _sizeservice
                                                          .createSize(sizeName,
                                                              sizeShortName);
                                                  if (result != null) {
                                                    fetchSize();
                                                    Navigator.pop(context);
                                                  } else {
                                                    showGlobalSnackBar(
                                                        'Failed to Create Size!');
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
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
                  isLoading
                      ? CircularProgressIndicator()
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Size ',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (_filteredSize.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'No Sizes are found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              else
                                ..._filteredSize.map((size) {
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
                                            'Size: ${size["sizeName"] ?? ""}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Size Short Name: ${size["sizeShortName"] ?? ""}',
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
                                                  final currentSize =
                                                      size['sizeName']
                                                              ?.toString() ??
                                                          '';
                                                  final currentSizeShortName =
                                                      size['sizeShortName']
                                                              ?.toString() ??
                                                          '';
                                                  String updatedSize =
                                                      currentSize;
                                                  String updatedSizeShortName =
                                                      currentSizeShortName;
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return StatefulBuilder(
                                                            builder: (context,
                                                                setState) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                'Edit Size'),
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
                                                                            text:
                                                                                updatedSize),
                                                                    onChanged:
                                                                        (value) {
                                                                      updatedSize =
                                                                          value;
                                                                    },
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText:
                                                                          'Size',
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
                                                                            text:
                                                                                updatedSizeShortName),
                                                                    onChanged:
                                                                        (value) {
                                                                      updatedSizeShortName =
                                                                          value;
                                                                    },
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText:
                                                                          'Size Short Name',
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
                                                                  if (updatedSize
                                                                          .isEmpty ||
                                                                      updatedSizeShortName
                                                                          .isEmpty) {
                                                                    showGlobalSnackBar(
                                                                        'Please fill all fields');
                                                                    return;
                                                                  }
                                                                  await _sizeservice.updateSize(
                                                                      size['sizeCode']
                                                                              ?.toString() ??
                                                                          '',
                                                                      updatedSizeShortName,
                                                                      updatedSize);
                                                                  fetchSize();
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
                                                              )
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
                                                  final sizeCode =
                                                      size["sizeCode"];
                                                  if (sizeCode != null &&
                                                      sizeCode.isNotEmpty) {
                                                    await _sizeservice
                                                        .deleteSize(sizeCode);
                                                    fetchSize();
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
    ));
  }
}
