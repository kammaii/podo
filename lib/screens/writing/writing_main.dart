import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/writing/writing_controller.dart';
import 'package:podo/screens/writing/writing_question.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class WritingMain extends StatefulWidget {
  WritingMain({Key? key}) : super(key: key);

  @override
  State<WritingMain> createState() => _WritingMainState();
}

class _WritingMainState extends State<WritingMain> with SingleTickerProviderStateMixin {
  String lessonId = Get.arguments;
  List<WritingQuestion> questions = [];
  final rockets = ['rocket1', 'rocket2', 'rocket3'];
  final KO = 'ko';
  String fo = 'en'; //todo: UserInfo 의 language 로 설정하기
  late AnimationController animationController;
  late Animation<Offset> animationOffset;
  bool isVisible = false;
  Radius borderRadius = const Radius.circular(20);
  late Future future;
  WritingQuestion? selectedQuestion;
  final controller = Get.put(WritingController());
  int maxLength = 50;
  final textEditController = TextEditingController();

  @override
  void initState() {
    super.initState();
    future = Database().getDocs(collection: 'Lessons/$lessonId/LessonWritings', orderBy: 'orderId');
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animationOffset = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(animationController);
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  toggleVisibility() {
    setState(() {
      isVisible = !isVisible;
      if (isVisible) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
    });
  }

  Function? onSendBtn() {
    if (controller.isChecked) {
      return () {
        Get.dialog(
          AlertDialog(
            title: const Text(MyStrings.wantRequestCorrection),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(primary: MyColors.pink),
                child: const Text(MyStrings.cancel),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(primary: MyColors.purple),
                child: const Text(MyStrings.send),
              ),
            ],
          ),
        );
      };
    } else {
      return null;
    }
  }

  Widget getWritingList(int index) {
    WritingQuestion question = questions[index];
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          toggleVisibility();
          selectedQuestion = question;
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                alignment: Alignment.bottomLeft,
                scale: 0.8,
                child: Image.asset('assets/images/${rockets[question.level]}.png'),
              ),
              const SizedBox(height: 10),
              MyWidget().getTextWidget(
                text: question.title[KO] ?? '',
                size: 20,
                color: MyColors.navy,
              ),
              const SizedBox(height: 10),
              MyWidget().getTextWidget(
                text: question.title[fo] ?? '',
                color: MyColors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: MyWidget().getAppbar(title: MyStrings.writing),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyWidget().getTextWidget(
                            text: MyStrings.selectQuestion, isTextAlignCenter: true, color: MyColors.purple),
                        TextButton(
                            onPressed: () {},
                            child: const Text(MyStrings.myWritings,
                                style: TextStyle(
                                  color: MyColors.purple,
                                  decoration: TextDecoration.underline,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future: future,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        questions = [];
                        if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                          for (dynamic snapshot in snapshot.data) {
                            questions.add(WritingQuestion.fromJson(snapshot));
                          }
                          return ListView.builder(
                            itemCount: questions.length,
                            itemBuilder: (BuildContext context, int index) {
                              return getWritingList(index);
                            },
                          );
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: isVisible,
              child: GestureDetector(
                onTap: () {
                  if (isVisible) {
                    toggleVisibility();
                    textEditController.text = '';
                    FocusScope.of(context).unfocus();
                  }
                },
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  constraints: const BoxConstraints.expand(),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: SlideTransition(
                position: animationOffset,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 2 / 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: borderRadius, topRight: borderRadius),
                    color: Colors.white,
                  ),
                  child: GetBuilder<WritingController>(
                    builder: (_) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: TextButton(
                                      onPressed: () {},
                                      child: const Text(MyStrings.viewOtherUsersWriting,
                                          style: TextStyle(
                                            color: MyColors.purple,
                                            decoration: TextDecoration.underline,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            MyWidget().getTextWidget(
                              text: selectedQuestion != null ? selectedQuestion!.title[KO] : '',
                              isKorean: true,
                              size: 20,
                            ),
                            const SizedBox(height: 20),
                            const SizedBox(height: 10),
                            MyWidget().getTextFieldWidget(
                              controller: textEditController,
                              maxLength: maxLength,
                              hint: MyStrings.writeYourAnswerInKorean,
                              fontSize: 15,
                            ),
                            const SizedBox(height: 30),
                            MyWidget().getRoundBtnWidget(
                              text: MyStrings.correction,
                              textSize: 15,
                              bgColor: MyColors.purple,
                              fontColor: Colors.white,
                              f: onSendBtn,
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                controller.setCheckbox(!controller.isChecked);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MyWidget()
                                      .getCheckBox(value: controller.isChecked, onChanged: controller.setCheckbox),
                                  MyWidget().getTextWidget(text: MyStrings.iveReadTheFollowing),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                                child: SingleChildScrollView(
                                    child: MyWidget()
                                        .getTextWidget(text: MyStrings.writingComment, color: MyColors.grey))),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
