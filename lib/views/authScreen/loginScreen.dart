import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/consts/list.dart';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:e_comapp/views/Users_Routes_Roles_Menus/Roles/Menus/roles.dart';
import 'package:e_comapp/views/authScreen/signupScreen.dart';
import 'package:e_comapp/views/homeScreen/homenav.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:e_comapp/views/widgets_common/custom_textfield.dart';
import 'package:e_comapp/views/widgets_common/our_button.dart';
import 'package:e_comapp/services/authservice.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  _LoginscreenState createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final AuthService _authService = AuthService(); // Instance of AuthService
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;
  String? _errorMessage;

  void _login() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    final response = await _authService.login(
      _phoneController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (response.containsKey('error')) {
      _errorMessage = response['error'];
      showGlobalSnackBar("Invalid credentials. Please try again.");
      print('Login Error: $_errorMessage');
      return;
    }

    final token = response['token'];
    print('Token received: $token');

    try {
      if (JwtDecoder.isExpired(token)) {
        showGlobalSnackBar("Session expired. Please log in again.");
        return;
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      print('Decoded Token: $decodedToken');

      final role = decodedToken['role'];
      print('User Role: $role');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);

      if (role == 'INDIVIDUAL') {
        Get.offAll(() => Home());
        showGlobalSnackBar("Welcome, User!");
      } else {
        // Get.offAll(() => Authnav());
        Get.offAll(() => Roles());
        showGlobalSnackBar("Welcome!");
      }
    } catch (e) {
      showGlobalSnackBar("Login failed. Please try again.");
      print('Token Decoding Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: context.screenHeight * 0.1),
            applogoWidget(),
            10.heightBox,
            "Log in to $appname".text.fontFamily(bold).white.size(18).make(),
            10.heightBox,
            Column(
              children: [
                customTextField(
                  hint: phonenoHint,
                  title: phoneno,
                  isPass: false,
                  controller: _phoneController,
                ),
                customTextField(
                  hint: passwordHint,
                  title: password,
                  isPass: true,
                  controller: _passwordController,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {},
                      child: forgetPass.text.color(Colors.blue).make()),
                ),
                5.heightBox,
                ourButton(
                  color: redColor,
                  title: login,
                  textColor: whiteColor,
                  onPress: _login,
                ).box.width(context.screenWidth - 50).make(),
                5.heightBox,
                createNewAccount.text.color(fontGrey).make(),
                5.heightBox,
                ourButton(
                    color: redColor,
                    title: signup,
                    textColor: whiteColor,
                    onPress: () {
                      Get.to(() => const Signupscreen());
                    }).box.width(context.screenWidth - 50).make(),
                10.heightBox,
                loginwith.text.color(fontGrey).make(),
                5.heightBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: lightGrey,
                        radius: 25,
                        child: Image.asset(
                          socailIconList[index],
                          width: 30,
                        ),
                      ),
                    ),
                  ),
                )
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
    ));
  }
}
