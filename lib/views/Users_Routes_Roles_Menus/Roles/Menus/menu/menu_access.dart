import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/services/fetch_roles_for_menu.dart';
import 'package:e_comapp/services/menuService.dart';
import 'package:e_comapp/services/menu_access_service.dart';
import 'package:e_comapp/utils/snackbar_util.dart';

import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';

class MenuAccess extends StatefulWidget {
  const MenuAccess({super.key});

  @override
  State<MenuAccess> createState() => _MenuAccessState();
}

class _MenuAccessState extends State<MenuAccess> {
  final String baseUrl = "https://localhost:7157";
  final UserService _userService = UserService();
  final MenuService _menuService = MenuService();
  final MenuAccessService _menuAccessService = MenuAccessService();
  final searchController = TextEditingController();
  bool isActive = false;
  bool isLoading = false;
  String? selectedRoleCode;
  Set<String> selectedMenus = {};
  List<Map<String, dynamic>> userData = [];
  List<Map<String, dynamic>> roles2 = [];
  List<Map<String, dynamic>> menuData = [];
  Map<String, bool> switches = {};

  @override
  void initState() {
    super.initState();
    fetchRoles();
    fetchMenuData();
  }

  Future<void> fetchMenuData() async {
    setState(() => isLoading = true);

    final menus = await _menuService.fetchMenuandSubmenu(); // Debugging

    if (menus.isEmpty) {}

    setState(() {
      menuData = List<Map<String, dynamic>>.from(menus); // Ensure correct type
      for (var menu in menuData) {
        switches[menu['menuCode']] = false;
        if (menu['subMenus'] != null) {
          for (var sub in menu['subMenus']) {
            switches[sub['menuCode']] = false;
          }
        }
      }
      isLoading = false;
    });
  }

  Future<void> fetchRoles() async {
    setState(() {
      isLoading = true; // Show loading spinner
    });
    final roles = await _userService.fetchRoles();
    setState(() {
      userData = roles; // Update the userData list with fetched roles
      isLoading = false; // Hide loading spinner
    });
  }

  bool isMenuChecked(String menuCode, List<dynamic>? subMenus) {
    // Check karega ki menu ya submenus selected hain ya nahi
    return selectedMenus.contains(menuCode) ||
        (subMenus != null &&
            subMenus.any((sub) => selectedMenus.contains(sub['menuCode'])));
  }

  void toggleMenu(bool value, String menuCode, List<dynamic>? subMenus) {
    setState(() {
      switches[menuCode] = value;

      if (value) {
        selectedMenus.add(menuCode);

        // ✅ If activating parent, activate all submenus
        if (subMenus != null) {
          for (var sub in subMenus) {
            switches[sub['menuCode']] = true;
            selectedMenus.add(sub['menuCode']);
          }
        }
      } else {
        selectedMenus.remove(menuCode);

        // ✅ If deactivating parent, deactivate all submenus
        if (subMenus != null) {
          for (var sub in subMenus) {
            switches[sub['menuCode']] = false;
            selectedMenus.remove(sub['menuCode']);
          }
        }
      }

      // ✅ If any submenu is active, parent should also be active
      for (var menu in menuData) {
        if (menu['subMenus'] != null &&
            menu['subMenus']
                .any((sub) => selectedMenus.contains(sub['menuCode']))) {
          switches[menu['menuCode']] = true;
          selectedMenus.add(menu['menuCode']);
        }
      }
    });
  }

  Future<void> saveMenuAccess() async {
    if (selectedRoleCode == null) {
      showGlobalSnackBar("Please select a role before saving.");
      return;
    }

    setState(() => isLoading = true);

    try {
      List<Map<String, dynamic>> menuAccessList = [];

      // ✅ Save Parent + Submenus Status
      switches.forEach((menuCode, status) {
        menuAccessList.add({
          'roleCode': selectedRoleCode!,
          'menuCode': menuCode,
          'status': status, // ✅ Ensure correct status is saved
        });
      });

      final response =
          await _menuAccessService.createMenuAccess(menuAccessList);

      if (response != null) {
        showGlobalSnackBar("Menu access updated successfully!");
      } else {
        print("Failed to update menu access.");
      }
    } catch (e) {
      print("Error updating menu access: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchMenuAccessByRole(String roleCode) async {
    setState(() => isLoading = true);

    try {
      final List<Map<String, dynamic>> accessList =
          await _menuAccessService.fetchMenuByRoleCode(roleCode);

      switches.clear();
      selectedMenus.clear();

      // ✅ Store all menu access data first
      for (var access in accessList) {
        String menuCode = access['menuCode'];
        bool status = access['status'];

        switches[menuCode] = status;
        if (status) {
          selectedMenus.add(menuCode);
        }
      }

      // ✅ Ensure submenus retain their saved state
      for (var menu in menuData) {
        if (menu['subMenus'] != null) {
          for (var sub in menu['subMenus']) {
            String subCode = sub['menuCode'];
            if (switches.containsKey(subCode)) {
              // Apply the saved state correctly
              switches[subCode] = switches[subCode] ?? false;
              if (switches[subCode]!) {
                selectedMenus.add(subCode);
              }
            }
          }
        }
      }

      setState(() {});
    } catch (e) {
      print("Error fetching menu access: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildMenuItem(Map<String, dynamic> item, {bool isSubMenu = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: isSubMenu ? 20.0 : 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['menuName'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSubMenu
                      ? FontWeight.normal
                      : FontWeight.bold, // Regular for submenus
                ),
              ),
              Switch(
                value: isMenuChecked(item['menuCode'], item['subMenus']),
                onChanged: (value) =>
                    toggleMenu(value, item['menuCode'], item['subMenus']),
                activeColor: Colors.green,
                inactiveTrackColor:
                    Colors.grey[300], // Background color for inactive state
                inactiveThumbColor:
                    Colors.grey, // Thumb color for inactive state
              )
            ],
          ),
        ),
        if (item['subMenus'] != null && item['subMenus'].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              children: item['subMenus']
                  .map<Widget>((sub) => buildMenuItem(sub, isSubMenu: true))
                  .toList(),
            ),
          ),
        Divider(
            thickness: 1, color: Colors.grey.shade300), // Thin separator line
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      Scaffold(
        body: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: context.screenHeight * 0.02),
                applogoWidget(),
                10.heightBox,
                "Menu Access With Role"
                    .text
                    .fontFamily(bold)
                    .color(Colors.white)
                    .size(18)
                    .make(),
                15.heightBox,
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
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(children: [
                      // Dropdown Button wrapped in Flexible
                      Flexible(
                        child: DropdownButton<String>(
                          hint: const Text("Select Role "), // Default hint
                          value:
                              selectedRoleCode, // Currently selected roleCode
                          items: userData.map((role) {
                            return DropdownMenuItem<String>(
                              value:
                                  role['roleCode'], // Use roleCode as the value
                              child: Text(role['roleName'] ??
                                  "Unknown"), // Display roleName
                            );
                          }).toList(),
                          onChanged: (String? roleCode) async {
                            setState(() {
                              selectedRoleCode = roleCode;
                            });

                            if (selectedRoleCode != null) {
                              List<Map<String, dynamic>> menuAccessList =
                                  await _menuAccessService
                                      .fetchMenuByRoleCode(selectedRoleCode!);

                              setState(() {
                                switches.clear();
                                selectedMenus.clear();

                                for (var menu in menuAccessList) {
                                  String menuCode =
                                      menu['menuCode']; // Extract menuCode
                                  bool status = menu['status'] ??
                                      false; // Ensure status is boolean

                                  switches[menuCode] =
                                      status; // Toggle based on status
                                  if (status) {
                                    selectedMenus.add(menuCode);
                                  }
                                }
                              });
                            }
                          },

                          isExpanded:
                              true, // Ensures the dropdown takes the full width
                        ),
                      ),
                      20.widthBox,
                    ]),
                    SizedBox(height: 20),
                    isLoading
                        ? CircularProgressIndicator()
                        : menuData.isEmpty
                            ? Text("Data exists but UI is not displaying it!",
                                style: TextStyle(color: Colors.white))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: menuData.map<Widget>((item) {
                                  return buildMenuItem(item);
                                }).toList(),
                              )
                                .box
                                .white
                                .padding(const EdgeInsets.all(16))
                                .shadowSm
                                .make(),
                    20.heightBox,
                    Center(
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : saveMenuAccess, // Disable button when loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text("Save",
                                style: TextStyle(color: Colors.white)),
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
