import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:flutter/material.dart';

class MenuAccess extends StatefulWidget {
  const MenuAccess({super.key});

  @override
  State<MenuAccess> createState() => _MenuAccessState();
}

class _MenuAccessState extends State<MenuAccess> {
  final searchController = TextEditingController();
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
            "Menu Access"
                .text
                .fontFamily(bold)
                .color(Colors.white)
                .size(18)
                .make(),
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
        )),
      ),
    );
  }
}
