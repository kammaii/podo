import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_date_format.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/loading_controller.dart';
import 'package:podo/screens/profile/user_info.dart';
import 'package:podo/screens/writing/writing.dart';
import 'package:podo/screens/writing/writing_controller.dart';
import 'package:podo/values/my_colors.dart';
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
  List<String> statusList = [
    MyStrings.writingStatus0,
    MyStrings.writingStatus1,
    MyStrings.writingStatus2,
    MyStrings.writingStatus3
  ];
  List<Color> statusColors = [MyColors.green, MyColors.purple, MyColors.mustard, MyColors.red];
  DocumentSnapshot? lastSnapshot;

  loadWritings({bool isContinue = false}) async {
    final ref = FirebaseFirestore.instance.collection('Writings');
    Query query;

    if (widget.isMyWritings) {
      query = ref
          .where('userEmail', isEqualTo: User().email)
          .orderBy('dateWriting', descending: true)
          .limit(docsLimit);
    } else {
      query = ref
          .where('questionId', isEqualTo: questionId!)
          .where('userEmail', isNotEqualTo: User().email)
          .where('status', whereIn: [1, 2])
          .orderBy('dateWriting', descending: true)
          .limit(docsLimit);
    }

    if (isContinue) {
      query = query.startAfterDocument(lastSnapshot!);
    }

    List<dynamic> snapshots = await Database().getDocs(query: query);

    if (snapshots.isNotEmpty) {
      for (dynamic snapshot in snapshots) {
        Writing writing = Writing.fromJson(snapshot.data() as Map<String, dynamic>);
        writings.add(writing);
      }
      lastSnapshot = snapshots.last;
    }
    controller.update();
  }

  Widget getItem(String title, String content) {
    return Row(
      children: [
        MyWidget().getTextWidget(text: '$title. ', isBold: true),
        const SizedBox(width: 15),
        Expanded(child: MyWidget().getTextWidget(text: content, isKorean: true, height: 1.5)),
      ],
    );
  }

  Widget getWritingList(int index) {
    Writing writing = writings[index];
    int status = writing.status;

    if (widget.isMyWritings) {
      return MyWidget().getRoundedContainer(
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MyWidget().getRoundedContainer(
                    widget: MyWidget().getTextWidget(text: statusList[status], color: Colors.white),
                    radius: 20,
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 13),
                    bgColor: statusColors[status]),
                const SizedBox(width: 10),
                Expanded(
                    child: MyWidget().getTextWidget(
                        text: 'Lv.${(writing.questionLevel + 1).toString()}', color: MyColors.grey)),
                Text(MyDateFormat().getDateFormat(writing.dateWriting)),
              ],
            ),
            const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getItem('Q', writing.questionTitle),
                const SizedBox(height: 15),
                getItem('A', writing.userWriting),
                const SizedBox(height: 15),
                getItem('C', writing.correction),
              ],
            ),
          ],
        ),
      );
    } else {
      return MyWidget().getRoundedContainer(
        widget: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(writing.userEmail),
              ],
            ),
            const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getItem('A', writing.userWriting),
                const SizedBox(height: 10),
                getItem('C', writing.correction),
              ],
            ),
          ],
        ),
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
    writings = [];
    lastSnapshot = null;

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
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: writings.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: getWritingList(index),
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
