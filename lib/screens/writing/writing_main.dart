import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/screens/writing/writing.dart';
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
  String fo = User().language;
  late AnimationController animationController;
  late Animation<Offset> animationOffset;
  bool isVisible = false;
  Radius borderRadius = const Radius.circular(20);
  late Future<List<dynamic>> futures;
  WritingQuestion? selectedQuestion;
  final controller = Get.find<WritingController>();
  int maxLength = 50;
  final textEditController = TextEditingController();
  int maxRequestCount = 3;
  int? requestCount;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final Query questionQuery = firestore.collection('Lessons/$lessonId/WritingQuestions').orderBy('orderId');
    final Query countQuery =
        firestore.collection('Writings').where('userId', isEqualTo: User().id).where('status', isEqualTo: 0);
    futures = Future.wait([
      Database().getDocs(query: questionQuery),
      countQuery.count().get(),
    ]);

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
        textEditController.text = '';
        FocusScope.of(context).unfocus();
      }
    });
  }

  Function? onSendBtn() {
    if (controller.isChecked) {
      return () {
        MyWidget().showDialog(content: MyStrings.wantRequestCorrection, yesFn: () {
          //todo: await FirebaseAnalytics.instance.logEvent(name: 'correction_request');
          Writing writing = Writing(selectedQuestion!);
          writing.userWriting = textEditController.text;
          Get.back();
          toggleVisibility();
          Database().setDoc(
              collection: 'Writings',
              doc: writing,
              thenFn: (value) {
                Get.snackbar(MyStrings.requestedCorrection, '');
                controller.leftRequestCount.value--;
              });
        });
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
          if (controller.leftRequestCount.value > 0) {
            toggleVisibility();
            selectedQuestion = question;
          } else {
            Get.dialog(
              AlertDialog(
                title: const Text(MyStrings.requestNotAvailableTitle),
                content: const Text(MyStrings.requestNotAvailableContent),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: MyColors.purple),
                    child: const Text(MyStrings.ok),
                  ),
                ],
              ),
            );
          }
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MyWidget().getAppbar(
        title: MyStrings.writing,
        actions: [
          Row(
            children: [
              Transform.scale(
                scale: 0.5,
                child: Image.asset('assets/images/podo.png'),
              ),
              Padding(
                  padding: const EdgeInsets.only(right: 20, top: 10),
                  child: Obx(() =>
                      MyWidget().getTextWidget(text: 'x ${controller.leftRequestCount}', color: MyColors.purple))),
            ],
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: MyWidget().getTextWidget(
                        text: MyStrings.selectQuestion, isTextAlignCenter: true, color: MyColors.purple),
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future: futures,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        questions = [];
                        if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                          for (dynamic snapshot in snapshot.data[0]) {
                            questions.add(WritingQuestion.fromJson(snapshot.data() as Map<String, dynamic>));
                          }
                          WidgetsBinding.instance!.addPostFrameCallback((_) {
                            controller.leftRequestCount.value = maxRequestCount - snapshot.data[1].count as int;
                          });
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
                                    onPressed: () {
                                      Get.toNamed(MyStrings.routeOtherWritingList,
                                          arguments: selectedQuestion!.id);
                                    },
                                    child: const Text(MyStrings.viewOtherUsersWriting,
                                        style: TextStyle(
                                          color: MyColors.purple,
                                          decoration: TextDecoration.underline,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ))),
                              ],
                            ),
                            const SizedBox(height: 20),
                            MyWidget().getTextWidget(
                              text: selectedQuestion != null ? selectedQuestion!.title[KO] : '',
                              isKorean: true,
                              size: 20,
                            ),
                            const SizedBox(height: 30),
                            MyWidget().getTextFieldWidget(
                              controller: textEditController,
                              maxLength: maxLength,
                              maxLines: 1,
                              hint: MyStrings.writeYourAnswerInKorean,
                              onSubmitted: (value) {
                                FocusScope.of(context).unfocus();
                              }
                            ),
                            const SizedBox(height: 30),
                            MyWidget().getRoundBtnWidget(
                              text: MyStrings.correction,
                              textSize: 15,
                              f: onSendBtn,
                              hasNullFunction: true,
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
