import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/fcm_request.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/responsive_size.dart';
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

class _WritingMainState extends State<WritingMain>
    with SingleTickerProviderStateMixin {
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
  late ResponsiveSize rs;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final Query questionQuery = firestore
        .collection('Lessons/$lessonId/WritingQuestions')
        .orderBy('orderId');
    final Query countQuery = firestore
        .collection('Writings')
        .where('userId', isEqualTo: User().id)
        .where('status', isEqualTo: 0);
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

    controller.isChecked = LocalStorage().prefs!.getBool(tr('iveReadTheFollowing')) ?? false;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  toggleVisibility({bool askFcmApproval = false}) {
    setState(() {
      isVisible = !isVisible;
      if (isVisible) {
        animationController.forward();
      } else {
        animationController.reverse();
        textEditController.text = '';
        FocusScope.of(context).unfocus();
      }
      if (askFcmApproval) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          MyWidget().showDialog(context, rs,
              content: tr('askFcmApproval'),
              yesFn: () async {
                await FcmRequest().fcmRequest('writingCorrection');
                Get.back();
              },
              hasNoBtn: false,
              yesText: tr('askFcmApprovalYes'),
              textBtnText: tr('later'),
              textBtnFn: () {
                Get.back();
              });
        });
      }
    });
  }

  Function? onSendBtn() {
    if (controller.isChecked) {
      return () {
        MyWidget().showDialog(context, rs, content: tr('wantRequestCorrection'),
            yesFn: () async {
          await FirebaseAnalytics.instance.logEvent(
              name: 'correction_request', parameters: {'userId': User().id});
          Writing writing = Writing(selectedQuestion!);
          writing.userWriting = textEditController.text;
          Get.back();
          toggleVisibility(askFcmApproval: !User().fcmPermission);
          await Database().setDoc(
              collection: 'Writings',
              doc: writing,
              thenFn: (value) {
                Get.snackbar(tr('requestedCorrection'), '');
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
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: () {
          if (controller.leftRequestCount.value > 0) {
            toggleVisibility();
            selectedQuestion = question;
          } else {
            Get.dialog(
              AlertDialog(
                title: Text(tr('requestNotAvailableTitle'),
                    style: TextStyle(
                        fontSize: rs.getSize(18),
                        color: Theme.of(context).secondaryHeaderColor)),
                content: Text(tr('requestNotAvailableContent'),
                    style: TextStyle(
                        fontSize: rs.getSize(15),
                        color: Theme.of(context).secondaryHeaderColor)),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                    child: MyWidget().getTextWidget(rs,
                        text: tr('ok'), color: Theme.of(context).cardColor),
                  ),
                ],
              ),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(rs.getSize(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                alignment: Alignment.bottomLeft,
                scale: 0.8,
                child:
                    Image.asset('assets/images/${rockets[question.level]}.png'),
              ),
              SizedBox(height: rs.getSize(10)),
              MyWidget().getTextWidget(
                rs,
                text: question.title[KO] ?? '',
                size: 20,
                color: Theme.of(context).primaryColorDark,
              ),
              SizedBox(height: rs.getSize(10)),
              MyWidget().getTextWidget(
                rs,
                text: question.title[fo] ?? '',
                color: Theme.of(context).disabledColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    rs = ResponsiveSize(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MyWidget().getAppbar(
        context,
        rs,
        title: tr('writing'),
        actions: [
          Row(
            children: [
              Transform.scale(
                scale: rs.getSize(0.5),
                child: Image.asset('assets/images/podo.png'),
              ),
              Padding(
                  padding: EdgeInsets.only(
                      right: rs.getSize(20), top: rs.getSize(10)),
                  child: Obx(() => MyWidget().getTextWidget(rs,
                      text: 'x ${controller.leftRequestCount}',
                      color: Theme.of(context).primaryColor))),
            ],
          )
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(rs.getSize(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rs.getSize(10)),
                  child: MyWidget().getTextWidget(rs,
                      text: tr('selectQuestion'),
                      isTextAlignCenter: true,
                      color: Theme.of(context).primaryColor),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: futures,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      questions = [];
                      if (snapshot.hasData &&
                          snapshot.connectionState != ConnectionState.waiting) {
                        for (dynamic snapshot in snapshot.data[0]) {
                          questions.add(WritingQuestion.fromJson(
                              snapshot.data() as Map<String, dynamic>));
                        }
                        WidgetsBinding.instance!.addPostFrameCallback((_) {
                          controller.leftRequestCount.value =
                              maxRequestCount - snapshot.data[1].count as int;
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
                  borderRadius: BorderRadius.only(
                      topLeft: borderRadius, topRight: borderRadius),
                  color: Theme.of(context).cardColor,
                ),
                child: GetBuilder<WritingController>(
                  builder: (_) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: rs.getSize(15)),
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
                                  child: MyWidget().getTextWidget(
                                    rs,
                                    text: tr('viewOtherUsersWriting'),
                                    color: Theme.of(context).primaryColor,
                                    hasUnderline: true,
                                    isBold: true,
                                  )),
                            ],
                          ),
                          SizedBox(height: rs.getSize(20)),
                          MyWidget().getTextWidget(rs,
                              text: selectedQuestion != null
                                  ? selectedQuestion!.title[KO]
                                  : '',
                              isKorean: true,
                              size: 20,
                              color: Theme.of(context).secondaryHeaderColor),
                          SizedBox(height: rs.getSize(30)),
                          MyWidget().getTextFieldWidget(context, rs,
                              controller: textEditController,
                              maxLength: maxLength,
                              maxLines: 1,
                              hint: tr('writeYourAnswerInKorean'),
                              onSubmitted: (value) {
                            FocusScope.of(context).unfocus();
                          }),
                          SizedBox(height: rs.getSize(30)),
                          MyWidget().getRoundBtnWidget(rs,
                              text: tr('correction'),
                              textSize: 15,
                              f: onSendBtn,
                              hasNullFunction: true,
                              bgColor: Theme.of(context).primaryColor,
                              fontColor: Theme.of(context).cardColor),
                          SizedBox(height: rs.getSize(10)),
                          GestureDetector(
                            onTap: () {
                              controller.setCheckbox(!controller.isChecked);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyWidget().getCheckBox(rs,
                                    value: controller.isChecked,
                                    onChanged: controller.setCheckbox),
                                MyWidget().getTextWidget(rs,
                                    text: tr('iveReadTheFollowing'),
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ],
                            ),
                          ),
                          SizedBox(height: rs.getSize(20)),
                          Expanded(
                              child: SingleChildScrollView(
                                  child: MyWidget().getTextWidget(rs,
                                      text: tr('writingComment'),
                                      color: Theme.of(context).disabledColor))),
                          SizedBox(height: rs.getSize(20)),
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
    );
  }
}
