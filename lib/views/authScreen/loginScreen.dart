import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/consts/list.dart';
import 'package:e_comapp/views/adminpanel/authnav.dart';
import 'package:e_comapp/views/authScreen/signupScreen.dart';
import 'package:e_comapp/views/category_screen/category_item_details.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:e_comapp/views/widgets_common/custom_textfield.dart';
import 'package:e_comapp/views/widgets_common/our_button.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "https://localhost:7157";

  Future<Map<String, dynamic>> login(
      String phoneNumber, String password) async {
    final url = Uri.parse('$baseUrl/register/authenticate');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userName': phoneNumber, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Invalid credentials'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> signUp(
      String name, String mobileNumber, String password) async {
    final url = Uri.parse('$baseUrl/register/individual');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'name': name, 'mobileNumber': mobileNumber, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Registration failed'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  _LoginscreenState createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final AuthService _authService = AuthService();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _authService.login(
      _phoneController.text,
      _passwordController.text,
    );
// Log the response

    setState(() {
      _isLoading = false;
    });

    if (response.containsKey('error')) {
      setState(() {
        _errorMessage = response['error'];
      });
      print('Error: $_errorMessage');
    } else {
      final token = response['token'];
      print('Token: $token');

      try {
        if (JwtDecoder.isExpired(token)) {
          setState(() {
            _errorMessage = "Token has expired. Please log in again.";
          });
          return;
        }

        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        print('Decoded Token: $decodedToken');

        final role = decodedToken['role'];
        print('Role: $role');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);

        if (role == 'INDIVIDUAL') {
          Get.to(() => Home());
          showFloatingSnackBar("Welcome User");
        } else if (role == 'newRole15545') {
          Get.to(() => Authnav());
          showFloatingSnackBar("Welcome SUPER ADMIN");
        } else {
          setState(() {
            _errorMessage = "Unknown role. Access denied.";
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = "Invalid token or decoding error: ${e.toString()}";
        });
        print('Decoding Error: $e');
      }
    }
  }

  // Function to show the floating snackbar
  void showFloatingSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          fontSize: 16, // Customize font size
          color: Colors.white, // Customize text color
        ),
      ),
      duration:
          Duration(seconds: 3), // Set the duration (3 seconds in this example)
      backgroundColor: Colors.red, // Customize background color
      behavior: SnackBarBehavior.floating, // Make it float above other elements
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
