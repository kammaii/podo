import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:podo/common_widgets/my_text_widget.dart';
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
            child: const Icon(FontAwesomeIcons.check),
            backgroundColor: MyColors.green,
          ),
          const SizedBox(height: 5),
          MyTextWidget().getTextWidget(MyStrings.correction, 15, MyColors.green,),
          const SizedBox(height: 10),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: (){},
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: MyColors.purple,
        ),
        title: MyTextWidget().getTextWidget(MyStrings.title, 18, MyColors.purple,),
      ),
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
            child: MyTextWidget().getTextWidget(MyStrings.expression, 15, Colors.white,),
            decoration: BoxDecoration(
              color: MyColors.purple,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextWidget().getTextWidget('~아/어요', 20, MyColors.purple, isBold: true,),
                  const SizedBox(height: 10),
                  MyTextWidget().getTextWidget('This expression means ~~', 15, MyColors.grey,),
                  const SizedBox(height: 20),
                  Row(
                    //todo: generate 로 바꾸기
                    children: [
                      MyTextWidget().getTextWidget('예문', 18, MyColors.purple,),
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
