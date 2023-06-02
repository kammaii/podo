import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/writing/writing_question.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class WritingListMain extends StatelessWidget {
  WritingListMain({Key? key}) : super(key: key);
  List<WritingQuestion> questions = [];
  final rockets = ['rocket1', 'rocket2', 'rocket3'];
  final KO = 'ko';
  String fo = 'en'; //todo: UserInfo 의 language 로 설정하기

  Widget getWritingList(int index) {
    WritingQuestion question = questions[index];
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
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
    String lessonId = Get.arguments;

    return SafeArea(
      child: Scaffold(
        appBar: MyWidget().getAppbar(title: ''),
        body: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              MyWidget()
                  .getTextWidget(text: MyStrings.selectQuestion, isTextAlignCenter: true, color: MyColors.navy),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder(
                  future: Database().getDocs(collection: 'Lessons/$lessonId/LessonWritings', orderBy: 'orderId'),
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
      ),
    );
  }
}
