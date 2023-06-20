import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/items/subscribe_items.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class PremiumMain extends StatelessWidget {
  PremiumMain({Key? key}) : super(key: key);
  late List<SubscribeItem> items;
  late List<bool> selector;
  late int selectedPlan;

  DataColumn getDataColumn(String label) {
    return DataColumn(
      label: Expanded(
        child: Center(child: MyWidget().getTextWidget(text: label)),
      ),
    );
  }

  DataRow getDataRow(String title, Widget basic, Widget premium) {
    return DataRow(cells: <DataCell>[
      DataCell(MyWidget().getTextWidget(text: title)),
      DataCell(Center(child: basic)),
      DataCell(Center(child: premium)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyWidget().getAppbar(title: ''),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('assets/images/quote_upper.png', color: MyColors.purple),
                          const SizedBox(width: 5),
                          Expanded(
                              child: MyWidget().getTextWidget(
                                  text: MyStrings.premiumComment,
                                  color: MyColors.purple,
                                  isTextAlignCenter: true,
                                  size: 20)),
                          const SizedBox(width: 5),
                          Image.asset('assets/images/quote_lower.png', color: MyColors.purple),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DataTable(
                        horizontalMargin: 0,
                        columns: <DataColumn>[
                          getDataColumn(''),
                          getDataColumn('Basic'),
                          getDataColumn('Premium'),
                        ],
                        rows: <DataRow>[
                          getDataRow(
                              MyStrings.lesson,
                              const Icon(Icons.check_circle_outline, color: MyColors.green),
                              const Icon(Icons.check_circle_outline, color: MyColors.green)),
                          getDataRow(
                              MyStrings.writingCorrection,
                              const Icon(Icons.remove_circle_outline, color: MyColors.red),
                              const Icon(Icons.check_circle_outline, color: MyColors.green)),
                          getDataRow(MyStrings.reading, MyWidget().getTextWidget(text: MyStrings.few),
                              MyWidget().getTextWidget(text: MyStrings.all)),
                          getDataRow(MyStrings.flashcard, MyWidget().getTextWidget(text: MyStrings.limit20),
                              MyWidget().getTextWidget(text: MyStrings.unlimited)),
                          getDataRow(
                              MyStrings.cloudMessage,
                              const Icon(Icons.remove_circle_outline, color: MyColors.red),
                              const Icon(Icons.check_circle_outline, color: MyColors.green)),
                          getDataRow(
                              MyStrings.adFree,
                              const Icon(Icons.remove_circle_outline, color: MyColors.red),
                              const Icon(Icons.check_circle_outline, color: MyColors.green))
                        ],
                      ),
                      const Divider(height: 30, thickness: 2, color: MyColors.purple),
                      MyWidget().getTextWidget(
                        text: MyStrings.premiumDetail,
                        size: 15,
                        color: MyColors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){},
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [MyColors.purple, MyColors.green]),
                            borderRadius: BorderRadius.circular(30)
                          ),
                          child: Row(
                            children: [
                              const Icon(FontAwesomeIcons.crown, color: Colors.white, size: 30),
                              const SizedBox(width: 20),
                              Expanded(child: Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyWidget().getTextWidget(text: MyStrings.twoMonths, color: Colors.white, size: 18, isBold: true),
                                    MyWidget().getTextWidget(text: MyStrings.hassleFree, color: Colors.white)
                                  ],
                                ),
                              )),
                              const SizedBox(width: 20),
                              MyWidget().getTextWidget(text: '\$10', color: Colors.white, size: 18, isBold: true),

                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
