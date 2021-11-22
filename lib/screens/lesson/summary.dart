import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
          const Text(
            MyStrings.correction,
            style: TextStyle(
              color: MyColors.green,
            ),
          ),
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
        title: const Text(
          MyStrings.title,
          style: TextStyle(
            color: MyColors.purple,
          ),
        ),
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
            child: const Text(
              MyStrings.expression,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
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
                  const Text(
                    '~아/어요',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: MyColors.purple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'This expression means ~~',
                    style: TextStyle(
                      color: MyColors.grey,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    //todo: generate 로 바꾸기
                    children: [
                      const Text(
                        '예문~~',
                        style: TextStyle(fontSize: 18, color: MyColors.purple),
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
