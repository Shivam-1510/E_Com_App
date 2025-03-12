import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/services/Manage%20Products/colorservice.dart';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:e_comapp/views/widgets_common/drawer.dart';

class Color2 extends StatefulWidget {
  const Color2({super.key});
  @override
  State<Color2> createState() => _Color2State();
}

class _Color2State extends State<Color2> {
  final Colorservice _colorservice = Colorservice();
  final searchController = TextEditingController();
  final TextEditingController colorNameController = TextEditingController();
  bool isLoading = true;
  bool isActive = false;
  List<dynamic> _color = [];
  List<dynamic> _filteredColor = [];
  List<dynamic> colorItems = [];

  @override
  void initState() {
    super.initState();
    fetchColor();
    searchController.addListener(() {
      filterColor(searchController.text);
    });
  }

  Future<void> fetchColor() async {
    final colors = await _colorservice.fetchColor();
    if (colors != null) {
      setState(() {
        _color = colors;
        _filteredColor = colors;
        colorItems = _color.map((colors) {
          return {
            "colorCode": colors["colorCode"].toString(),
            "colorName": colors["colorName"],
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

  void filterColor(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredColor = _color;
      } else {
        _filteredColor = _color.where((colors) {
          final colorName = colors["colorName"]?.toLowerCase() ?? "";
          return colorName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(Scaffold(
      appBar: AppBar(
          title: Text(
            'Colour',
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
                  // Search field
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        colorNameController.clear();
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
                                            'Create Colour',
                                            style: TextStyle(
                                                fontFamily: bold, fontSize: 18),
                                          ),
                                          SizedBox(height: 20),
                                          TextField(
                                            controller: colorNameController,
                                            decoration: InputDecoration(
                                              labelText: 'Colour Name',
                                              border: OutlineInputBorder(),
                                            ),
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
                                                  )),
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    final colorName =
                                                        colorNameController
                                                            .text;
                                                    if (colorName.isEmpty) {
                                                      showGlobalSnackBar(
                                                          'Colour name is required!');
                                                    }
                                                    final result =
                                                        await _colorservice
                                                            .createColor(
                                                                colorName);
                                                    if (result != null) {
                                                      fetchColor();
                                                      Navigator.pop(context);
                                                    } else {
                                                      showGlobalSnackBar(
                                                          'Failed to create Colour!');
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              redColor),
                                                  child: Text(
                                                    'Save',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ))
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
                                  'Colour',
                                  style:
                                      TextStyle(fontFamily: bold, fontSize: 22),
                                ),
                              ),
                              if (_filteredColor.isEmpty)
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'No Colours found',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                )
                              else
                                ..._filteredColor.map((color) {
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
                                            'Colour: ${color['colorName'] ?? ""}',
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
                                                  final currentColorName =
                                                      color['colorName']
                                                              ?.toString() ??
                                                          '';
                                                  String updateColorName =
                                                      currentColorName;
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return StatefulBuilder(
                                                            builder: (context,
                                                                setState) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                'Edit Colour'),
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
                                                                          updateColorName,
                                                                    ),
                                                                    onChanged:
                                                                        (value) {
                                                                      updateColorName =
                                                                          value;
                                                                    },
                                                                    decoration: InputDecoration(
                                                                        labelText:
                                                                            'Colour',
                                                                        border:
                                                                            OutlineInputBorder()),
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
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        backgroundColor:
                                                                            redColor),
                                                                onPressed:
                                                                    () async {
                                                                  if (updateColorName
                                                                      .isEmpty) {
                                                                    showGlobalSnackBar(
                                                                        'Please fill all fields');
                                                                    return;
                                                                  }
                                                                  await _colorservice.updateColor(
                                                                      color['colorCode']
                                                                              ?.toString() ??
                                                                          '',
                                                                      updateColorName);
                                                                  fetchColor();
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
                                                  final colorCode =
                                                      color['colorCode'];
                                                  if (colorCode != null &&
                                                      colorCode.isNotEmpty) {
                                                    await _colorservice
                                                        .deletecolor(colorCode);
                                                    fetchColor();
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
    ));
  }
}
