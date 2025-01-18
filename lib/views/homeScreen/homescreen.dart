import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/consts/list.dart';
import 'package:e_comapp/views/homeScreen/components/featuredButtons.dart';
import 'package:e_comapp/views/widgets_common/homebuttons.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: lightGrey,
      width: context.screenWidth,
      height: context.screenWidth,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 60,
              color: lightGrey,
              child: TextFormField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: whiteColor,
                  hintText: searchanything,
                  hintStyle: TextStyle(color: textfieldGrey),
                ),
              ),
            ),
            10.heightBox,
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    VxSwiper.builder(
                      aspectRatio: 16 / 9,
                      autoPlay: true,
                      height: 150,
                      enlargeCenterPage: true,
                      itemCount: slidersList.length,
                      itemBuilder: (context, index) {
                        return Image.asset(
                          slidersList[index],
                          fit: BoxFit.fill,
                        )
                            .box
                            .rounded
                            .clip(Clip.antiAlias)
                            .margin(EdgeInsets.symmetric(horizontal: 8))
                            .make();
                      },
                    ),
                    10.heightBox,
                    // Deals buttons with proper spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        homeButtons(
                          height: context.screenHeight * 0.15,
                          width: context.screenWidth / 2.5,
                          icon: icTodaysDeal,
                          title: todayDeal,
                        ),
                        SizedBox(width: 10), // Add spacing between buttons
                        homeButtons(
                          height: context.screenHeight * 0.15,
                          width: context.screenWidth / 2.5,
                          icon: icFlashDeal,
                          title: flashsale,
                        ),
                      ],
                    ),
                    10.heightBox,
                    VxSwiper.builder(
                      aspectRatio: 16 / 9,
                      autoPlay: true,
                      height: 150,
                      enlargeCenterPage: true,
                      itemCount: secondSlidersList.length,
                      itemBuilder: (context, index) {
                        return Image.asset(
                          secondSlidersList[index],
                          fit: BoxFit.fill,
                        )
                            .box
                            .rounded
                            .clip(Clip.antiAlias)
                            .margin(EdgeInsets.symmetric(horizontal: 8))
                            .make();
                      },
                    ),
                    // Category buttons
                    10.heightBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                          3,
                          (index) => homeButtons(
                              height: context.screenHeight * 0.15,
                              width: context.screenWidth / 3.5,
                              icon: index == 0
                                  ? icTopCategories
                                  : index == 1
                                      ? icBrands
                                      : icTopSeller,
                              title: index == 0
                                  ? topCategories
                                  : index == 1
                                      ? brand
                                      : topSellers)),
                    ),
                    // featured categories
                    20.heightBox,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: featuredCategories.text
                          .color(darkFontGrey)
                          .size(18)
                          .fontFamily(semibold)
                          .make(),
                    ),
                    20.heightBox,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          children: List.generate(
                              3,
                              (index) => Column(
                                    children: [
                                      featuredButton(
                                          icon: featuredImages1[index],
                                          title: featuredTitle1[index]),
                                      10.heightBox,
                                      featuredButton(
                                        icon: feturedImages2[index],
                                        title: featuredTitle2[index],
                                      ),
                                    ],
                                  ))),
                    ),
                    // featured Product
                    10.heightBox,
                    Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: const BoxDecoration(color: redColor),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            featuredProduct.text.white
                                .fontFamily(bold)
                                .size(18)
                                .make(),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(
                                    6,
                                    (index) => Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                              imgP1,
                                              width: 150,
                                              fit: BoxFit.cover,
                                            ),
                                            10.heightBox,
                                            "Laptop 4GB/64GB"
                                                .text
                                                .fontFamily(semibold)
                                                .color(darkFontGrey)
                                                .make(),
                                            10.heightBox,
                                            "\$600"
                                                .text
                                                .color(redColor)
                                                .fontFamily(bold)
                                                .size(16)
                                                .make()
                                          ],
                                        )
                                            .box
                                            .white
                                            .roundedSM
                                            .margin(EdgeInsets.symmetric(
                                                horizontal: 8))
                                            .padding(const EdgeInsets.all(4))
                                            .make()),
                              ),
                            ),
                          ],
                        )),
                    // THird swiper
                    20.heightBox,
                    VxSwiper.builder(
                      aspectRatio: 16 / 9,
                      autoPlay: true,
                      height: 150,
                      enlargeCenterPage: true,
                      itemCount: secondSlidersList.length,
                      itemBuilder: (context, index) {
                        return Image.asset(
                          secondSlidersList[index],
                          fit: BoxFit.fill,
                        )
                            .box
                            .rounded
                            .clip(Clip.antiAlias)
                            .margin(EdgeInsets.symmetric(horizontal: 8))
                            .make();
                      },
                    ),
                    // All Products Section
                    20.heightBox,
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio:
                            0.7, // Adjust this ratio to fix overflow
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                imgP5,
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                              10.heightBox,
                              "Purse".text.fontFamily(semibold).make(),
                              5.heightBox,
                              "\$100"
                                  .text
                                  .color(redColor)
                                  .fontFamily(bold)
                                  .size(16)
                                  .make(),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            )
            // Swipers brand
          ],
        ),
      ),
    );
  }
}
