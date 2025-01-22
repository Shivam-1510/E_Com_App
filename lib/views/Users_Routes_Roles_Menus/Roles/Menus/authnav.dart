import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/controller/home_controller.dart';
import 'package:e_comapp/views/Users_Routes_Roles_Menus/Roles/Menus/menu/menu_access.dart';
import 'package:e_comapp/views/Users_Routes_Roles_Menus/Roles/Menus/roles.dart';
import 'package:e_comapp/views/Users_Routes_Roles_Menus/Roles/Menus/menu/menu.dart';
import 'package:e_comapp/views/Users_Routes_Roles_Menus/Roles/Menus/routes/routes.dart';
import 'package:e_comapp/views/Users_Routes_Roles_Menus/Roles/Menus/routes/routes_access.dart';
import 'package:e_comapp/views/Users_Routes_Roles_Menus/Roles/Menus/user_role.dart';
import 'package:get/get.dart';

class Authnav extends StatelessWidget {
  const Authnav({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize home controller
    var controller = Get.put(HomeController());

    var navbarItem = [
      BottomNavigationBarItem(
          icon: Image.asset(
            icHome,
            width: 26,
            color: Vx.white,
          ),
          label: 'Roles'),
      BottomNavigationBarItem(
          icon: Image.asset(
            icCategories,
            width: 26,
            color: whiteColor,
          ),
          label: 'Users'),
      BottomNavigationBarItem(
          icon: Image.asset(
            icWholeSale,
            width: 26,
            color: Vx.white,
          ),
          label: 'Menu'),
      BottomNavigationBarItem(
          icon: Image.asset(
            icWholeSale,
            width: 26,
            color: Vx.white,
          ),
          label: 'Menu Access'),
      BottomNavigationBarItem(
          icon: Image.asset(
            icProfile,
            width: 26,
            color: whiteColor,
          ),
          label: 'Routes'),
      BottomNavigationBarItem(
          icon: Image.asset(
            icProfile,
            width: 26,
            color: whiteColor,
          ),
          label: 'Routes Access')
    ];

    var navBody = [
      Roles(),
      UserRole(),
      Menu(),
      MenuAccess(),
      Routes(),
      RoutesAccess()
    ];

    return Scaffold(
      body: Column(
        children: [
          // Use the built-in Obx widget to listen to changes and update the UI
          Obx(() => Expanded(
                child: navBody.elementAt(controller.currentNavIndex.value),
              )),
        ],
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentNavIndex.value,
          selectedItemColor: whiteColor,
          selectedLabelStyle: const TextStyle(fontFamily: semibold),
          type: BottomNavigationBarType.fixed,
          backgroundColor: redColor,
          items: navbarItem,
          onTap: (value) {
            controller.currentNavIndex.value = value;
          },
        ),
      ),
    );
  }
}
