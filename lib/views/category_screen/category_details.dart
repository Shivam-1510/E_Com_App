import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/views/category_screen/category_item_details.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class CategoryDetails extends StatelessWidget {
  final String? title;
  const CategoryDetails({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return bgWidget(Scaffold(
      appBar: AppBar(
        title: title!.text.fontFamily(bold).white.make(),
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                    6,
                    (index) => "Baby Clothing"
                        .text
                        .size(12)
                        .fontFamily(semibold)
                        .color(darkFontGrey)
                        .makeCentered()
                        .box
                        .white
                        .rounded
                        .size(120, 60)
                        .margin(const EdgeInsets.symmetric(horizontal: 4))
                        .make()),
              ),
            ),
            20.heightBox,
            // Items Container
            Expanded(
              child: GridView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: 6,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisExtent: 250),
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        imgP5,
                        height: 150,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                      "Laptop 4GB/ 64GB"
                          .text
                          .fontFamily(semibold)
                          .color(darkFontGrey)
                          .make(),
                      10.heightBox,
                      "\$200"
                          .text
                          .color(redColor)
                          .fontFamily(bold)
                          .size(16)
                          .make(),
                      10.heightBox,
                    ],
                  )
                      .box
                      .white
                      .margin(const EdgeInsets.symmetric(horizontal: 4))
                      .roundedSM
                      .outerShadowSm
                      .padding(const EdgeInsets.all(12))
                      .make()
                      .onTap(() {
                    Get.to(() => const ItemsDetails(title: "Dummy Item"));
                  });
                },
              ),
            )
          ],
        ),
      ),
    ));
  }
}
