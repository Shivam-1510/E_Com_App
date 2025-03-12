import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/views/authScreen/loginScreen.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:get/get.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  // Creating a method tp chnage screen
  changeScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.to(() => const Loginscreen());
    });
  }

  @override
  void initState() {
    changeScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: redColor,
      body: Center(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                icSplashBg,
                width: 300,
              ),
            ),
            20.heightBox, // Adds spacing of 20 pixels
            applogoWidget(),
            10.heightBox,
            appname.text.fontFamily(bold).size(22).white.make(),
            5.heightBox,
            appversion.text.white.make(),
            const Spacer(),
            credits.text.white.fontFamily(semibold).make(),
          ],
        ),
      ),
    );
  }
}
