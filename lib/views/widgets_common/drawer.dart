import 'package:e_comapp/views/Manage%20Product/brand.dart';
import 'package:e_comapp/views/Manage%20Product/category.dart';
import 'package:e_comapp/views/Manage%20Product/color.dart';
import 'package:e_comapp/views/Manage%20Product/products.dart';
import 'package:e_comapp/views/Manage%20Product/size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:e_comapp/views/Users_Routes_Roles_Menus/Roles/Menus/menu/menu.dart';
import 'package:e_comapp/views/Users_Routes_Roles_Menus/Roles/Menus/menu/menu_access.dart';
import 'package:e_comapp/views/Users_Routes_Roles_Menus/Roles/Menus/roles.dart';
import 'package:e_comapp/views/Users_Routes_Roles_Menus/Roles/Menus/routes/routes.dart';
import 'package:e_comapp/views/Users_Routes_Roles_Menus/Roles/Menus/routes/routes_access.dart';
import 'package:e_comapp/views/Users_Routes_Roles_Menus/Roles/Menus/users.dart';
import 'package:e_comapp/views/authScreen/loginScreen.dart';
import 'package:e_comapp/services/drawerservice.dart';
import 'package:e_comapp/services/getloginuesrrole.dart';
import 'package:e_comapp/utils/snackbar_util.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final UserRoleService _userRoleService = UserRoleService();
  final Drawerservice _drawerservice = Drawerservice();
  Map<String, dynamic>? loggedInUser;
  String? roleCode;
  List<Map<String, dynamic>> accessedMenus = [];
  String? activeMenu; // Store active menu

  @override
  void initState() {
    super.initState();
    fetchLoggedInUserDetails();
    _setActiveMenu(); // Set active menu on drawer open
  }

  Future<void> fetchLoggedInUserDetails() async {
    final userDetails = await _userRoleService.getUserDetails();
    if (userDetails != null && userDetails.containsKey('user')) {
      setState(() {
        loggedInUser = userDetails['user'];
        roleCode = userDetails['userRoles'][0]['roleCode'].toString();
      });
      fetchMenus();
    }
  }

  Future<void> fetchMenus() async {
    if (roleCode == null) return;
    final menus = await _drawerservice.fetchMenuByRoleCode(roleCode!);
    setState(() {
      accessedMenus = menus;
    });
  }

  void _setActiveMenu() {
    String currentRoute = Get.currentRoute; // Get the current route

    Map<String, String> routeMapping = {
      "/users": "Users",
      "/roles": "Roles",
      "/menus": "Menus",
      "/menu-access": "Menu Access",
      "/routes": "Routes",
      "/route-access": "Route Access",
    };

    setState(() {
      activeMenu = routeMapping[currentRoute] ?? null;
    });
  }

  void _logout() async {
    await _storage.delete(key: 'authToken');
    String? token = await _storage.read(key: 'authToken');

    if (token == null) {
      Get.to(() => const Loginscreen());
      showGlobalSnackBar("Logged Out");
    } else {
      Get.snackbar('Error', 'Could not log out. Please try again.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _navigateToPage(String menuName, String route) {
    setState(() {
      activeMenu = menuName; // Set active menu on click
    });

    switch (menuName) {
      case "Users":
        Get.to(() => UserRole());
        break;
      case "Roles":
        Get.to(() => Roles());
        break;
      case "Menus":
        Get.to(() => Menu());
        break;
      case "Menu Access":
        Get.to(() => MenuAccess());
        break;
      case "Route Access":
        Get.to(() => RoutesAccess());
        break;
      case "Routes":
        Get.to(() => Routes());
        break;
      case "Brand":
        Get.to(() => Brand());
        break;
      case "Category":
        Get.to(() => Category2());
        break;
      case "Colour":
        Get.to(() => Color2());
        break;
      case "Size":
        Get.to(() => Size2());
        break;
      case "Product":
        Get.to(() => Products());
        break;
      default:
        Get.snackbar('Error', 'Page not found',
            backgroundColor: Colors.red, colorText: Colors.white);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.red),
            accountName: Text(
              loggedInUser?['name'] ?? "Admin Panel",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              loggedInUser?['eMail'] ?? "Admin Panel",
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.red),
            ),
          ),
          Expanded(
            child: ListView(
              children: accessedMenus.map((menu) {
                return _buildDrawerItem(menu);
              }).toList(),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.redAccent),
            title: Text("Logout",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(Map<String, dynamic> menu) {
    String menuName = menu['menuName'] ?? "Unknown";
    List subMenus = menu['subMenus'] ?? [];
    bool isActive = menuName == activeMenu; // Check if menu is active

    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.menu, color: isActive ? Colors.blue : Colors.red),
          title: Text(
            menuName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.blue : Colors.black,
            ),
          ),
          onTap: () => _navigateToPage(menuName, Get.currentRoute),
        ),
        if (subMenus.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Column(
              children: subMenus.map((subMenu) {
                String subMenuName = subMenu['menuName'] ?? "Unknown";
                bool isSubActive = subMenuName == activeMenu;

                return ListTile(
                  leading: Icon(Icons.subdirectory_arrow_right,
                      color: isSubActive ? Colors.blue : Colors.redAccent),
                  title: Text(
                    subMenuName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSubActive ? FontWeight.bold : FontWeight.w500,
                      color: isSubActive ? Colors.blue : Colors.black,
                    ),
                  ),
                  onTap: () => _navigateToPage(subMenuName, Get.currentRoute),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
