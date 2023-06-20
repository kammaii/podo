import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/items/subscribe_items.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class Subscribe extends StatefulWidget {
  const Subscribe({Key? key}) : super(key: key);

  @override
  _SubscribeState createState() => _SubscribeState();
}

class _SubscribeState extends State<Subscribe> {
  late List<SubscribeItem> items;
  late List<bool> selector;
  late int selectedPlan;

  @override
  void initState() {
    super.initState();
    items = SubscribeItems().items;
    selector = [true, false];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors.purpleLight,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Positioned(
                top: 16,
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.keyboard_arrow_left_rounded),
                    color: MyColors.purple,
                    iconSize: 40),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                    child: MyWidget().getTextWidget(
                      text: MyStrings.getPremium,
                      size: 25,
                      color: MyColors.purple,
                      isBold: true,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 270,
                            child: Swiper(
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return getCards(index);
                              },
                              pagination: const SwiperPagination(
                                  builder: DotSwiperPaginationBuilder(color: MyColors.grey)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          getPlan(selector[0], true, MyStrings.yearly, '000 dollar', '000 dollar',
                              detail: '(000/month)'),
                          getPlan(selector[1], false, MyStrings.monthly, '000 dollar', '000 dollar'),
                          TextButton(
                            child: MyWidget().getTextWidget(
                              text: MyStrings.purchaseRestoration,
                              size: 15,
                              color: MyColors.purple,
                            ),
                            onPressed: () {},
                          ),
                          const SizedBox(height: 150),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: MyWidget().getRoundBtnWidget(
                            text: 'MyStrings.getPremium',
                            f: () {},
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: MyColors.purpleLight,
                    padding: const EdgeInsets.all(8),
                    child: MyWidget().getTextWidget(
                      text: MyStrings.premiumDetail,
                      size: 15,
                      color: MyColors.grey,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getCards(int index) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
                BoxShadow(
                  color: MyColors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                )
              ]),
              child: Icon(
                items[index].icon,
                size: 50,
                color: MyColors.purple,
              )),
          const SizedBox(height: 20),
          MyWidget().getTextWidget(
            text: items[index].title,
            size: 20,
            color: MyColors.purple,
          ),
          const SizedBox(height: 10),
          MyWidget().getTextWidget(
            text: items[index].description,
            size: 15,
            color: MyColors.grey,
            isTextAlignCenter: true,
          ),
        ],
      ),
    );
  }

  Widget getPlan(bool isSelected, bool isDiscounted, String title, String exPrice, String price,
      {String? detail}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDiscounted)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: const BoxDecoration(color: MyColors.purple),
              child: MyWidget().getTextWidget(
                text: MyStrings.bestValue,
                size: 15,
                color: Colors.white,
              ),
            ),
          GestureDetector(
            onTap: () {
              setState(() {
                selector = [false, false];
                isDiscounted ? selector[0] = true : selector[1] = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  border: isDiscounted ? Border.all(color: MyColors.purple) : Border.all(color: Colors.white),
                  color: Colors.white),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: isSelected ? MyColors.purple : MyColors.navyLightLight,
                    size: 50,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        MyWidget().getTextWidget(
                          text: title,
                          size: 20,
                          color: MyColors.purple,
                          isBold: true,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyWidget().getTextWidget(
                              text: exPrice,
                              size: 15,
                              color: MyColors.grey,
                              hasLineThrough: true,
                            ),
                            const SizedBox(width: 20),
                            MyWidget().getTextWidget(
                              text: price,
                              size: 18,
                              color: MyColors.purple,
                            ),
                          ],
                        ),
                        if (detail != null)
                          Column(
                            children: [
                              const SizedBox(height: 10),
                              MyWidget().getTextWidget(
                                text: detail,
                                size: 18,
                                color: MyColors.purple,
                              ),
                            ],
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
