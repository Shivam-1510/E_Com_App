import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/consts/list.dart';
import 'package:e_comapp/views/profile_screen/detailcard.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:get/get.dart'; // Add GetX for navigation
import 'package:e_comapp/views/authScreen/loginScreen.dart'; // Import login screen

class ProfileScreen extends StatelessWidget {
  final FlutterSecureStorage _storage =
      FlutterSecureStorage(); // Secure storage instance

  ProfileScreen({super.key});

  void _logout() async {
    // Delete the token from secure storage
    await _storage.delete(key: 'authToken');

    // Verify if the token was successfully deleted
    String? token = await _storage.read(key: 'authToken');

    if (token == null) {
      // Token is deleted, navigate to login screen
      Get.to(() => const Loginscreen());
    } else {
      // Error: Token could not be deleted, show error message
      // You can use a SnackBar or other widgets to show the error
      Get.snackbar('Error', 'Could not log out. Please try again.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              HeightBox(20),
              // Profile header section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profile image and info
                    Row(
                      children: [
                        // Profile image
                        Image.asset(
                          imgProfile2,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ).box.roundedFull.clip(Clip.antiAlias).make(),
                        const SizedBox(
                            width: 10), // Adds spacing between image and text
                        // User info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            "Dummy User"
                                .text
                                .fontFamily(semibold)
                                .white
                                .size(18)
                                .make(),
                            "customer@example.com"
                                .text
                                .fontFamily(regular)
                                .white
                                .size(14)
                                .make(),
                          ],
                        ),
                      ],
                    ),

                    // Logout button
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                      onPressed: _logout, // Call logout function
                      child: "Logout"
                          .text
                          .fontFamily(semibold)
                          .color(Colors.white)
                          .make(),
                    ),
                  ],
                ),
              ),

              // Add space between the header and the cards
              const SizedBox(height: 30),

              // Detail cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  detailCard(
                    cont: "00",
                    title: "In Your Cart",
                    width: context.screenWidth / 3.2,
                  ),
                  detailCard(
                    cont: "02",
                    title: "In Wishlist",
                    width: context.screenWidth / 3.2,
                  ),
                  detailCard(
                    cont: "05",
                    title: "Orders",
                    width: context.screenWidth / 3.2,
                  ),
                ],
              ),

              // Add space between the detail cards and the list
              const SizedBox(height: 30),

              // List view section
              ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: lightGrey,
                  );
                },
                itemCount: profileButtonsList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: Image.asset(
                      profileButtonsIcon[index],
                      width: 22,
                    ),
                    title: profileButtonsList[index]
                        .text
                        .fontFamily(semibold)
                        .color(darkFontGrey)
                        .make(),
                  );
                },
              )
                  .box
                  .white
                  .rounded
                  .shadowSm
                  .margin(const EdgeInsets.all(12))
                  .padding(const EdgeInsets.symmetric(horizontal: 16))
                  .make(),
            ],
          ),
        ),
      ),
    );
  }
}
