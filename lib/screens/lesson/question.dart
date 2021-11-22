import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podo/screens/lesson/btn_round.dart';
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
  final textFieldController = TextEditingController();
  final focusNode = FocusNode();
  bool isAskOpened = false;

  @override
  Widget build(BuildContext context) {
    double maxHeight;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: MyColors.purple,
        ),
        title: const Text(
          MyStrings.question,
          style: TextStyle(
            color: MyColors.purple,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                setState(() {
                  isAskOpened = false;
                  FocusScope.of(context).unfocus();
                  if (isInfoSelected) {
                    isInfoSelected = false;
                    infoIconColor = MyColors.grey;
                  } else {
                    isInfoSelected = true;
                    infoIconColor = MyColors.green;
                  }
                });
              },
              icon: const Icon(CupertinoIcons.info_circle_fill),
              color: infoIconColor,
            ),
          )
        ],
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn,
                        height: isInfoSelected ? 80 : 0,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: MyColors.greenLight,
                        ),
                        child: const Center(
                          child: Text(
                            MyStrings.questionInfo,
                            style: TextStyle(
                              color: MyColors.greenDark,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      prefixIcon: Icon(Icons.search),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0)),
                                        borderSide: BorderSide(
                                            color: MyColors.navyLight,
                                            width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0)),
                                        borderSide: BorderSide(
                                            color: MyColors.navyLight,
                                            width: 1.0),
                                      ),
                                      hintText: MyStrings.questionHint,
                                      filled: true,
                                      fillColor: Colors.white),
                                  controller: textFieldController,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                CupertinoIcons.ticket,
                                color: MyColors.purple,
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                '3',
                                style: TextStyle(
                                    color: MyColors.purple,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            MyStrings.bestQuestions,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              child: RoundBtn().getRoundBtn(
                                  false,
                                  MyStrings.askQuestion,
                                  MyColors.purple,
                                  Colors.white, () {
                                setState(() {
                                  isAskOpened = true;
                                });
                              }),
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
                      const Expanded(
                        child: Card(
                          child: TextField(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: RoundBtn().getRoundBtn(
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
                            child: RoundBtn().getRoundBtn(
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
              const Text(
                'Q',
                style: TextStyle(
                    fontSize: 35,
                    color: MyColors.purple,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: const Text(
                    MyStrings.lorem,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
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
                  child: const Text(
                    MyStrings.lorem,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'A',
                style: TextStyle(
                    fontSize: 35,
                    color: MyColors.purple,
                    fontWeight: FontWeight.bold),
              ),
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
