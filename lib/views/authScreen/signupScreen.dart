import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/views/homeScreen/homescreen.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:e_comapp/views/widgets_common/custom_textfield.dart';
import 'package:e_comapp/views/widgets_common/our_button.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_comapp/services/authservice.dart'; // Updated import path

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final AuthService _authService = AuthService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool? isCheck = false;
  bool _isLoading = false;
  String? _errorMessage;

  void _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call the signup function
      final response = await _authService.signUp(
        _nameController.text,
        _phoneController.text,
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.containsKey('error')) {
        // Show the error from the response
        setState(() {
          _errorMessage = response['error'];
        });
      } else if (response.containsKey('token')) {
        // Handle a successful response with a token
        final token = response['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token); // Save token locally
        Get.to(() => Homescreen());
      } else {
        // Handle an unexpected response structure
        setState(() {
          _errorMessage = "Unexpected response from the server.";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "An error occurred: $e";
      });
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
            "Join the $appname".text.fontFamily(bold).white.size(18).make(),
            10.heightBox,
            Column(
              children: [
                customTextField(
                  hint: nameHint,
                  title: name,
                  isPass: false,
                  controller: _nameController,
                ),
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
                    onPressed: () {
                      // Forgot password logic
                    },
                    child: forgetPass.text.color(Colors.blue).make(),
                  ),
                ),
                5.heightBox,
                Row(
                  children: [
                    Checkbox(
                      checkColor: redColor,
                      value: isCheck,
                      onChanged: (newValue) {
                        setState(() {
                          isCheck = newValue;
                        });
                      },
                    ),
                    10.widthBox,
                    Expanded(
                      child: RichText(
                        text: const TextSpan(children: [
                          TextSpan(
                              text: "I agree to the ",
                              style: TextStyle(
                                  fontFamily: regular, color: fontGrey)),
                          TextSpan(
                              text: termAndCond,
                              style: TextStyle(
                                fontFamily: regular,
                                color: redColor,
                              )),
                          TextSpan(
                              text: " & ",
                              style: TextStyle(
                                fontFamily: regular,
                                color: redColor,
                              )),
                          TextSpan(
                              text: privacyPolicy,
                              style: TextStyle(
                                  fontFamily: regular, color: redColor)),
                        ]),
                      ),
                    ),
                  ],
                ),
                20.heightBox,
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ourButton(
                  color: isCheck == true ? redColor : lightGrey,
                  title: signup,
                  textColor: whiteColor,
                  onPress: isCheck == true ? _signUp : null,
                ).box.width(context.screenWidth - 50).make(),
                10.heightBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    alreadyHaveAccount.text.color(fontGrey).make(),
                    login.text
                        .fontFamily(bold)
                        .color(redColor)
                        .make()
                        .onTap(() {
                      Get.back();
                    }),
                  ],
                )
              ],
            )
                .box
                .white
                .rounded
                .padding(EdgeInsets.all(16))
                .width(context.screenWidth - 70)
                .shadowSm
                .make(),
          ],
        ),
      ),
    ));
  }
}
