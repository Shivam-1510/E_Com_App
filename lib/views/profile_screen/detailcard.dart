import 'package:e_comapp/consts/consts.dart';

Widget detailCard({width, String? cont, String? title}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      "00".text.fontFamily(bold).color(darkFontGrey).make(),
      "in your cart ".text.color(darkFontGrey).make(),
    ],
  )
      .box
      .white
      .rounded
      .height(60)
      .width(width)
      .padding(const EdgeInsets.all(4))
      .make();
}
