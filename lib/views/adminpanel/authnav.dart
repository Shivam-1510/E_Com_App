import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/consts/images.dart';
import 'package:e_comapp/controller/home_controller.dart';
import 'package:e_comapp/views/adminpanel/adminpanel.dart';
import 'package:e_comapp/views/adminpanel/user_role.dart';
import 'package:e_comapp/views/profile_screen/profilescreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

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
          label: DashBoard),
      BottomNavigationBarItem(
          icon: Image.asset(
            icCategories,
            width: 26,
            color: whiteColor,
          ),
          label: userRole),
      // BottomNavigationBarItem(
      //     icon: Image.asset(icCart, width: 26), label: cart),
      BottomNavigationBarItem(
          icon: Image.asset(
            icProfile,
            width: 26,
            color: whiteColor,
          ),
          label: account)
    ];

    var navBody = [
      AdminPanel(),
      UserRole(),
      // CartScreen(),
      ProfileScreen()
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
