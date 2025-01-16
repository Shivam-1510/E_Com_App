import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/consts/images.dart';

Widget applogoWidget() {
  // Using Velocity x here
  return Image.asset(icAppLogo)
      .box
      .white
      .size(77, 77)
      .padding(EdgeInsets.all(8))
      .rounded
      .make();
}
