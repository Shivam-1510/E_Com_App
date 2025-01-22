import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/services/menuService.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final MenuService _menuService = MenuService();
  final searchController = TextEditingController();
  final TextEditingController menuNameController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  bool isLoading = true;
  bool isActive = false;
  List<dynamic> _menus = []; //list to hold the menu data
  List<dynamic> menuItems = []; // list to store the muenuitems
  String? selectedMenu;
  IconData? selectedIcon; //Add this to variable to keep track of sselected icon

  @override
  void initState() {
    super.initState();
    fetchMenus(); // Fetch menus on widget load
  }

  // Fetch menus using the MenuService
  Future<void> fetchMenus() async {
    final menus = await _menuService.fetchMenu();
    if (menus != null) {
      setState(() {
        _menus = menus;
        menuItems = _menus
            .map((menu) => menu["menuName"] ?? "No Parent")
            .toList(); // Set the parent names for the dropdown
        isLoading = false; // Set loading to false after data is fetched
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Failed to fetch menus");
    }
  }

  // load kr rha hai menu name ko
  void loadMenus() async {
    final menus = await _menuService.fetchMenu();
    if (menus != null) {
      setState(() {
        menuItems = menus.map((menu) => menu['name'].toString()).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      Scaffold(
        body: Center(
          child: Column(
            children: [
              SizedBox(height: context.screenHeight * 0.02),
              applogoWidget(),
              10.heightBox,
              "Menu".text.fontFamily(bold).color(Colors.white).size(18).make(),
              15.heightBox,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text(
                        "Create New ",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: bold,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
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
                                    padding: const EdgeInsets.all(16.0),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Title
                                          Text(
                                            "Create Menus",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: 'bold'),
                                          ),
                                          const SizedBox(height: 20),

                                          // User Name Field
                                          TextField(
                                            controller: menuNameController,
                                            decoration: const InputDecoration(
                                              labelText: "Menu Name",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          // Path
                                          TextField(
                                            controller: urlController,
                                            decoration: const InputDecoration(
                                              labelText: "Path",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 20),

                                          // Dropdown Parent Name
                                          DropdownButtonFormField<String>(
                                              decoration: const InputDecoration(
                                                labelText: "Parent Name",
                                                border: OutlineInputBorder(),
                                              ),
                                              value: selectedMenu,
                                              items: menuItems.map((menu) {
                                                return DropdownMenuItem<String>(
                                                  value: menu,
                                                  child: Text(menu),
                                                );
                                              }).toList(),
                                              onChanged: (newValue) {
                                                setState(() {
                                                  selectedMenu = newValue;
                                                });
                                              }),
                                          const SizedBox(height: 20),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Icons',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                  height:
                                                      10), // Gap after the heading
                                              Container(
                                                padding: EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 5,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: Wrap(
                                                  spacing: 20,
                                                  runSpacing: 20,
                                                  children: [
                                                    // Heart Icon
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedIcon =
                                                              FontAwesomeIcons
                                                                  .heart;
                                                        });
                                                      },
                                                      child: Icon(
                                                        FontAwesomeIcons.heart,
                                                        color: selectedIcon ==
                                                                FontAwesomeIcons
                                                                    .heart
                                                            ? Colors.green
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    // Home Icon
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedIcon =
                                                              FontAwesomeIcons
                                                                  .home;
                                                        });
                                                      },
                                                      child: Icon(
                                                        FontAwesomeIcons.home,
                                                        color: selectedIcon ==
                                                                FontAwesomeIcons
                                                                    .home
                                                            ? Colors.green
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    // Sitemap Icon
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedIcon =
                                                              FontAwesomeIcons
                                                                  .sitemap;
                                                        });
                                                      },
                                                      child: Icon(
                                                        FontAwesomeIcons
                                                            .sitemap,
                                                        color: selectedIcon ==
                                                                FontAwesomeIcons
                                                                    .sitemap
                                                            ? Colors.green
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    // Adjust Icon
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedIcon =
                                                              FontAwesomeIcons
                                                                  .adjust;
                                                        });
                                                      },
                                                      child: Icon(
                                                        FontAwesomeIcons.adjust,
                                                        color: selectedIcon ==
                                                                FontAwesomeIcons
                                                                    .adjust
                                                            ? Colors.green
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    // Brush Icon
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedIcon =
                                                              FontAwesomeIcons
                                                                  .brush;
                                                        });
                                                      },
                                                      child: Icon(
                                                        FontAwesomeIcons.brush,
                                                        color: selectedIcon ==
                                                                FontAwesomeIcons
                                                                    .brush
                                                            ? Colors.green
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    // Users Icon
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedIcon =
                                                              FontAwesomeIcons
                                                                  .users;
                                                        });
                                                      },
                                                      child: Icon(
                                                        FontAwesomeIcons.users,
                                                        color: selectedIcon ==
                                                                FontAwesomeIcons
                                                                    .users
                                                            ? Colors.green
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    // Phone Icon
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedIcon =
                                                              FontAwesomeIcons
                                                                  .phone;
                                                        });
                                                      },
                                                      child: Icon(
                                                        FontAwesomeIcons.phone,
                                                        color: selectedIcon ==
                                                                FontAwesomeIcons
                                                                    .phone
                                                            ? Colors.green
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    // File Icon
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedIcon =
                                                              FontAwesomeIcons
                                                                  .fileAlt;
                                                        });
                                                      },
                                                      child: Icon(
                                                        FontAwesomeIcons
                                                            .fileAlt,
                                                        color: selectedIcon ==
                                                                FontAwesomeIcons
                                                                    .fileAlt
                                                            ? Colors.green
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    // Tree Icon
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedIcon =
                                                              FontAwesomeIcons
                                                                  .tree;
                                                        });
                                                      },
                                                      child: Icon(
                                                        FontAwesomeIcons.tree,
                                                        color: selectedIcon ==
                                                                FontAwesomeIcons
                                                                    .tree
                                                            ? Colors.green
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    // Wrench Icon
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedIcon =
                                                              FontAwesomeIcons
                                                                  .wrench;
                                                        });
                                                      },
                                                      child: Icon(
                                                        FontAwesomeIcons.wrench,
                                                        color: selectedIcon ==
                                                                FontAwesomeIcons
                                                                    .wrench
                                                            ? Colors.green
                                                            : Colors.black,
                                                      ),
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
                                              .width(context.screenWidth - 70)
                                              .shadowSm
                                              .make(),
                                          SizedBox(height: 20),
                                          Text('Status: ',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                          Switch(
                                            value: isActive,
                                            onChanged: (value) {
                                              setState(() {
                                                isActive = value;
                                              });
                                            },
                                            activeColor: Colors.green,
                                            inactiveThumbColor: Colors.grey,
                                          ),
                                          Text(
                                            isActive ? 'Active' : 'Inactive',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isActive
                                                    ? Colors.green
                                                    : Colors.red),
                                          ),

                                          const SizedBox(height: 20),

                                          // Buttons
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                      color: redColor),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  // Get values from form fields
                                                  final menuName =
                                                      menuNameController.text;
                                                  final path =
                                                      urlController.text;
                                                  final icon = selectedIcon !=
                                                          null
                                                      ? selectedIcon!.codePoint
                                                          .toString()
                                                      : '';
                                                  // Dropdown value
                                                  final isActiveStatus =
                                                      isActive; // Switch status

                                                  // Call the createMenu function from MenuService
                                                  final result =
                                                      await _menuService
                                                          .createMenu(
                                                    menuName,
                                                    path,
                                                    icon,
                                                    isActiveStatus,
                                                  );

                                                  if (result != null) {
                                                    await _menuService
                                                        .fetchMenu();
                                                    // Successfully created the menu
                                                    print(
                                                        "Menu created successfully!");
                                                  } else {
                                                    // Failed to create menu
                                                    print(
                                                        "Failed to create menu.");
                                                  }

                                                  // Close the dialog after saving
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: Text(
                                                  "Save",
                                                  style: TextStyle(
                                                      color: Colors.white),
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
                      },
                    ),
                  ),
                  HeightBox(20),

                  // Table
                  isLoading
                      ? CircularProgressIndicator()
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 30,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  "Menu Name",
                                  style:
                                      TextStyle(fontFamily: bold, fontSize: 16),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Path",
                                  style:
                                      TextStyle(fontFamily: bold, fontSize: 16),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Actions",
                                  style:
                                      TextStyle(fontFamily: bold, fontSize: 16),
                                ),
                              ),
                            ],
                            rows: _menus.map((menu) {
                              return DataRow(cells: [
                                DataCell(Text(menu["menuName"] ?? "")),
                                DataCell(Text(menu["path"] ?? "")),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        print("Edit ${menu["menuName"]}");
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        print("Delete ${menu["menuName"]}");
                                      },
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                ],
              )
                  .box
                  .white
                  .rounded
                  .padding(const EdgeInsets.all(16))
                  .width(context.screenWidth - 70)
                  .shadowSm
                  .make(),
            ],
          ),
        ),
      ),
    );
  }
}
