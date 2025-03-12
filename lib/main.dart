import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/views/Splashscreen/splashscreen.dart';
import 'package:get/get.dart';
import 'utils/snackbar_util.dart';  // Utility function import karo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'e_comapp',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.transparent,
          appBarTheme: const AppBarTheme(
              iconTheme: IconThemeData(color: darkFontGrey),
              elevation: 0.0,
              backgroundColor: Colors.transparent),
          fontFamily: regular,
        ),
        scaffoldMessengerKey: scaffoldMessengerKey, // Set key here
        home: const Splashscreen());
  }
}
