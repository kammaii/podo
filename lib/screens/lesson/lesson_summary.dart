import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class LessonSummary extends StatelessWidget {
  const LessonSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {},
            backgroundColor: MyColors.green,
            child: const Icon(FontAwesomeIcons.check),
          ),
          const SizedBox(height: 5),
          MyWidget().getTextWidget(
            text: MyStrings.correction,
            size: 15,
            color: MyColors.green,
          ),
          const SizedBox(height: 10),
        ],
      ),
      appBar: MyWidget().getAppbar(context: context, title: MyStrings.title),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                getExpressions(),
                getExpressions(),
                getExpressions(),
                getExpressions(),
                getExpressions(),
                getExpressions(),
                getExpressions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getExpressions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: MyColors.purple,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: MyWidget().getTextWidget(
              text: MyStrings.expression,
              size: 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyWidget().getTextWidget(
                    text: '~아/어요',
                    size: 20,
                    color: MyColors.purple,
                    isBold: true,
                  ),
                  const SizedBox(height: 10),
                  MyWidget().getTextWidget(
                    text: 'This expression means ~~',
                    size: 15,
                    color: MyColors.grey,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    //todo: generate 로 바꾸기
                    children: [
                      MyWidget().getTextWidget(
                        text: '예문',
                        size: 18,
                        color: MyColors.purple,
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.volume_up_rounded),
                        color: MyColors.purple,
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
