import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_date_format.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/loading_controller.dart';
import 'package:podo/screens/profile/user.dart';
import 'package:podo/screens/writing/writing.dart';
import 'package:podo/screens/writing/writing_controller.dart';
import 'package:podo/values/my_strings.dart';

class WritingList extends StatefulWidget {
  WritingList(this.isMyWritings, {Key? key}) : super(key: key);

  bool isMyWritings = true;

  @override
  State<WritingList> createState() => _WritingListState();
}

class _WritingListState extends State<WritingList> {
  List<Writing> writings = [];
  final controller = Get.find<WritingController>();
  final scrollController = ScrollController();
  final docsLimit = 10;
  late String field;
  late String equalTo;
  String? questionId = Get.arguments;
  List<String> writingStatus = [MyStrings.writingStatus0, MyStrings.writingStatus1, MyStrings.writingStatus2, MyStrings.writingStatus3, MyStrings.writingStatus4];

  loadWritings({bool isContinue = false}) async {
    List<dynamic> snapshots = await Database().getDocs(
        collection: 'Writings',
        field: field,
        equalTo: equalTo,
        orderBy: 'dateWriting',
        limit: docsLimit,
        isContinue: isContinue);
    for (dynamic snapshot in snapshots) {
      Writing writing = Writing.fromJson(snapshot);
      writings.add(writing);
    }
    controller.update();
  }

  Widget getItem(String title, String content) {
    return Row(
      children: [
        MyWidget().getTextWidget(text: '$title. ', isBold: true),
        MyWidget().getTextWidget(text: content, isKorean: true),
      ],
    );
  }

  Widget getWritingList(int index) {
    Writing writing = writings[index];

    if(widget.isMyWritings) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(writingStatus[writing.status]),
              Text(MyDateFormat().getDateFormat(writing.dateWriting)),
            ],
          ),
          const SizedBox(height: 15),
          MyWidget().getWhiteContainer(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getItem('Q', writing.questionTitle),
                  const SizedBox(height: 10),
                  getItem('A', writing.userWriting),
                  const SizedBox(height: 10),
                  getItem('C', writing.correction),
                ],
              )
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(writing.userEmail),
            ],
          ),
          MyWidget().getWhiteContainer(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getItem('A', writing.userWriting),
                  const SizedBox(height: 10),
                  getItem('C', writing.correction),
                ],
              )
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMyWritings = widget.isMyWritings;

    if (isMyWritings) {
      field = 'userEmail';
      equalTo = User().email;
    } else {
      field = 'questionId';
      equalTo = questionId!;
      //todo: 해당 유저의 글 제외 / status 가 1,2 인 것만
    }

    loadWritings();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        LoadingController.to.isLoading = true;
        loadWritings(isContinue: true);
        LoadingController.to.isLoading = false;
      }
    });

    return SafeArea(
      child: Scaffold(
        appBar: MyWidget().getAppbar(title: isMyWritings ? MyStrings.myWritings : MyStrings.viewOtherUsersWriting),
        body: GetBuilder<WritingController>(
          builder: (_) {

            return Column(
              children: [
                ListView.builder(
                  itemCount: writings.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: getWritingList(index),
                    );
                  },
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
