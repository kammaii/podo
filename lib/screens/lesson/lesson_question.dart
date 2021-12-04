import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podo/common_widgets/my_widget.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class LessonQuestion extends StatefulWidget {
  const LessonQuestion({Key? key}) : super(key: key);

  @override
  _LessonQuestionState createState() => _LessonQuestionState();
}

class _LessonQuestionState extends State<LessonQuestion> {
  bool isInfoSelected = false;
  Color infoIconColor = MyColors.grey;
  late TextEditingController textFieldController;
  late FocusNode searchFocusNode;
  late FocusNode askFocusNode;
  bool isAskOpened = false;


  @override
  void initState() {
    super.initState();
    searchFocusNode = FocusNode();
    askFocusNode = FocusNode();
    textFieldController = TextEditingController();
  }


  @override
  void dispose() {
    super.dispose();
    searchFocusNode.dispose();
    askFocusNode.dispose();
    textFieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double maxHeight;
    if (!isInfoSelected) {
      infoIconColor = MyColors.grey;
    } else {
      infoIconColor = MyColors.green;
    }

    return Scaffold(
      appBar: MyWidget().getAppbarWithAction(
        MyStrings.question,
        () {
          setState(() {
            isAskOpened = false;
            FocusScope.of(context).unfocus();
            isInfoSelected = !isInfoSelected;
          });
        },
        infoIconColor
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            maxHeight = constraints.maxHeight;
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  children: [
                    MyWidget().getInfoWidget(isInfoSelected ? 80 : 0, MyStrings.questionInfo),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: MyWidget().getSearchWidget(searchFocusNode, textFieldController),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                CupertinoIcons.ticket,
                                color: MyColors.purple,
                              ),
                              const SizedBox(width: 5),
                              MyWidget().getTextWidget('3', 18, MyColors.purple, isBold: true,),
                            ],
                          ),
                          const SizedBox(height: 20),
                          MyWidget().getTextWidget(MyStrings.bestQuestions, 18, Colors.black, isBold: true,),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 100),
                              child: Column(
                                children: [
                                  getBestQuestions(),
                                  getBestQuestions(),
                                  getBestQuestions(),
                                  getBestQuestions(),
                                ],
                              ),
                            ),
                          ),
                          Padding(  // Ask a question 버튼
                            padding: const EdgeInsets.only(bottom: 15),
                            child: MyWidget().getRoundBtnWithAlert(
                              false,
                              MyStrings.askQuestion,
                              MyColors.purple,
                              Colors.white, () {
                                setState(() {
                                  isInfoSelected = false;
                                  isAskOpened = true;
                                  askFocusNode.requestFocus();
                                });
                              }
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isAskOpened ? maxHeight : 0,
                  curve: Curves.ease,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: MyColors.purpleLight,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: TextField(
                              focusNode: askFocusNode,
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              decoration: const InputDecoration.collapsed(
                                hintText: MyStrings.questionHint,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: MyWidget().getRoundBtnWidget(
                              false,
                              MyStrings.cancel,
                              MyColors.pink,
                              Colors.white,
                              () {
                                setState(() {
                                  isAskOpened = false;
                                  FocusScope.of(context).unfocus();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MyWidget().getRoundBtnWidget(
                              true,
                              MyStrings.send,
                              MyColors.purple,
                              Colors.white,
                              () {},
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget getBestQuestions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyWidget().getTextWidget('Q', 35, MyColors.purple, isBold: true,),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: MyWidget().getTextWidget(MyStrings.lorem, 15, Colors.black,),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: MyWidget().getTextWidget(MyStrings.lorem, 15, Colors.black,),
                ),
              ),
              const SizedBox(width: 10),
              MyWidget().getTextWidget('A', 35, MyColors.purple, isBold: true,),
            ],
          ),
          const Divider(
            height: 50,
            thickness: 1,
            indent: 30,
            endIndent: 30,
          ),
        ],
      ),
    );
  }
}
