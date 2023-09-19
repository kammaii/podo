import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/flashcard_icon.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_date_format.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/loading_controller.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/screens/writing/writing.dart';
import 'package:podo/screens/writing/writing_controller.dart';
import 'package:podo/values/my_colors.dart';
import 'package:html/parser.dart' as htmlParser;

class WritingMyList extends StatefulWidget {
  WritingMyList({Key? key}) : super(key: key);

  @override
  State<WritingMyList> createState() => _WritingMyListState();
}

class _WritingMyListState extends State<WritingMyList> {
  List<Writing> writings = [];
  final controller = Get.find<WritingController>();
  final scrollController = ScrollController();
  final docsLimit = 10;
  String? questionId = Get.arguments;
  List<String> statusList = [
    tr('writingStatus0'),
    tr('writingStatus1'),
    tr('writingStatus2'),
    tr('writingStatus3')
  ];
  List<Color> statusColors = [MyColors.mustard, MyColors.purple, MyColors.green, MyColors.red];
  DocumentSnapshot? lastSnapshot;
  bool isLoaded = false;
  bool hasMore = true;

  loadWritings({bool isContinue = false}) async {
    final ref = FirebaseFirestore.instance.collection('Writings');
    Query query =
        ref.where('userId', isEqualTo: User().id).orderBy('dateWriting', descending: true).limit(docsLimit);

    if (isContinue) {
      query = query.startAfterDocument(lastSnapshot!);
    }

    controller.isLoading.value = true;
    List<dynamic> snapshots = await Database().getDocs(query: query);
    controller.isLoading.value = false;
    writings = [];

    if (snapshots.isNotEmpty) {
      for (dynamic snapshot in snapshots) {
        Writing writing = Writing.fromJson(snapshot.data() as Map<String, dynamic>);
        print(writing.id);
        writings.add(writing);
        controller.hasFlashcard[writing.id] = LocalStorage().hasFlashcard(itemId: writing.id);
      }
      lastSnapshot = snapshots.last;
    }

    if (snapshots.length < docsLimit) {
      hasMore = false;
    }

    isLoaded = true;
    controller.update();
  }

  Widget getItem(Writing writing, {required String tag}) {
    String content = '';
    if (tag == 'Q') {
      content = writing.questionTitle;
    } else if (tag == 'A') {
      content = writing.userWriting;
    } else if (tag == 'C') {
      content = writing.correction;
    }
    String extractedText = htmlParser.parse(content).body!.text;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: tag == 'A' ? 10 : 0),
      child: Row(
        children: [
          MyWidget().getTextWidget(text: '$tag. ', isBold: true),
          const SizedBox(width: 15),
          Expanded(
            child: HtmlWidget(
              content,
              textStyle: const TextStyle(
                fontFamily: 'KoreanFont',
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          Visibility(
            visible: writing.status == 1 && tag.contains('C') || writing.status == 2 && tag.contains('A'),
            child: Obx(() =>
                FlashcardIcon().getIconButton(controller: controller, itemId: writing.id, front: extractedText)),
          )
        ],
      ),
    );
  }

  Widget getWritingList(int index) {
    Writing writing = writings[index];
    int status = writing.status;

    List<Widget> items = [];
    items.add(getItem(writing, tag: 'Q'));
    items.add(getItem(writing, tag: 'A'));
    if (writing.status != 0) {
      items.add(getItem(writing, tag: 'C'));
    }

    return MyWidget().getRoundedContainer(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MyWidget().getRoundedContainer(
                  widget: MyWidget().getTextWidget(text: statusList[status], color: Colors.white, size: 13),
                  radius: 20,
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  bgColor: statusColors[status]),
              const SizedBox(width: 10),
              Expanded(
                  child: MyWidget()
                      .getTextWidget(text: 'Lv.${(writing.questionLevel + 1).toString()}', color: MyColors.grey)),
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.keyboard_double_arrow_left_rounded, size: 13, color: MyColors.grey),
                      const SizedBox(width: 5),
                      MyWidget().getTextWidget(
                          text: MyDateFormat().getDateFormat(writing.dateWriting), size: 12, color: MyColors.grey),
                    ],
                  ),
                  writing.dateReply != null
                      ? Row(
                          children: [
                            const Icon(Icons.keyboard_double_arrow_right_rounded, size: 13, color: MyColors.grey),
                            const SizedBox(width: 5),
                            MyWidget().getTextWidget(
                                text: MyDateFormat().getDateFormat(writing.dateReply!),
                                size: 12,
                                color: MyColors.grey),
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ],
          ),
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    lastSnapshot = null;
    if (writings.isEmpty) { // TextField 로 인한 rebuild 방지용
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadWritings();
      });
    }

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && hasMore) {
        LoadingController.to.isLoading = true;
        loadWritings(isContinue: true);
        LoadingController.to.isLoading = false;
      }
    });

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          writings = [];
        });
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 15),
                child: MyWidget()
                    .getTextWidget(text: tr('myWritings'), color: MyColors.purple, isBold: true, size: 18),
              ),
              Expanded(
                child: Stack(
                  children: [
                    GetBuilder<WritingController>(
                      builder: (_) {
                        return Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Expanded(
                                child: isLoaded && writings.isEmpty
                                    ? Center(
                                        child: MyWidget().getTextWidget(
                                          text: tr('noMyWritings'),
                                          isTextAlignCenter: true,
                                          size: 18,
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: writings.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          print('MY');

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
                    Obx(() => Offstage(
                          offstage: !controller.isLoading.value,
                          child: Stack(
                            children: const [
                              Opacity(opacity: 0.3, child: ModalBarrier(dismissible: false, color: Colors.black)),
                              Center(
                                child: CircularProgressIndicator(),
                              )
                            ],
                          ),
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
