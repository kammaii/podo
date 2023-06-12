import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_date_format.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/loading_controller.dart';
import 'package:podo/screens/profile/user_info.dart';
import 'package:podo/screens/writing/writing.dart';
import 'package:podo/screens/writing/writing_controller.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:animated_icon/animated_icon.dart';

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
  String? questionId = Get.arguments;
  List<String> statusList = [
    MyStrings.writingStatus0,
    MyStrings.writingStatus1,
    MyStrings.writingStatus2,
    MyStrings.writingStatus3
  ];
  List<Color> statusColors = [MyColors.mustard, MyColors.purple, MyColors.green, MyColors.red];
  DocumentSnapshot? lastSnapshot;
  bool isLoaded = false;

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
          .where('userEmail', isEqualTo: User().email) //todo: isNotEqualTo 로 변경하기
          .where('status', whereIn: [1, 2])
          .orderBy('dateWriting', descending: true)
          .limit(docsLimit);
    }

    if (isContinue) {
      query = query.startAfterDocument(lastSnapshot!);
    }

    controller.isLoading.value = true;
    List<dynamic> snapshots = await Database().getDocs(query: query);
    controller.isLoading.value = false;

    if (snapshots.isNotEmpty) {
      for (dynamic snapshot in snapshots) {
        Writing writing = Writing.fromJson(snapshot.data() as Map<String, dynamic>);
        writings.add(writing);
      }
      lastSnapshot = snapshots.last;
    }
    isLoaded = true;
    controller.update();
  }

  Widget getItem(String title, String content, {Writing? writing}) {
    content = '<p>$content</p>';
    return Row(
      children: [
        MyWidget().getTextWidget(text: '$title. ', isBold: true),
        const SizedBox(width: 15),
        Expanded(
          child: Html(
            data: content,
            style: {
              'p': Style(
                  fontFamily: 'KoreanFont', fontSize: const FontSize(15), lineHeight: LineHeight.number(1.5)),
            },
          ),
        ),
        Visibility(
          visible: writing != null && writing.status == 1 && title.contains('C') ||
              writing != null && writing.status == 2 && title.contains('A'),
          child: Row(
            children: [
              const SizedBox(width: 10),
              AnimateIcon(
                onTap: () {
                  String extractedText = htmlParser.parse(content).body!.text;
                  FlashCard flashCard = FlashCard();
                  flashCard.front = extractedText;
                  flashCard.back = '';
                  Database().setFlashcard(flashCard: flashCard);
                },
                iconType: IconType.toggleIcon,
                animateIcon: AnimateIcons.heart,
                height: 20,
                width: 20,
                color: MyColors.purple,
              ),
            ],
          ),
        )
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
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.keyboard_double_arrow_left_rounded, size: 13, color: MyColors.grey),
                        const SizedBox(width: 5),
                        MyWidget().getTextWidget(
                            text: MyDateFormat().getDateFormat(writing.dateWriting),
                            size: 12,
                            color: MyColors.grey),
                      ],
                    ),
                    writing.dateReply != null
                        ? Row(
                            children: [
                              const Icon(Icons.keyboard_double_arrow_right_rounded,
                                  size: 13, color: MyColors.grey),
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
              children: [
                getItem('Q', writing.questionTitle),
                getItem('A', writing.userWriting, writing: writing),
                getItem('C', writing.correction, writing: writing),
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
                MyWidget().getTextWidget(text: writing.userEmail.split('@')[0], color: MyColors.grey),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadWritings();
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        LoadingController.to.isLoading = true;
        loadWritings(isContinue: true);
        LoadingController.to.isLoading = false;
      }
    });

    return Scaffold(
      appBar: MyWidget().getAppbar(title: isMyWritings ? MyStrings.myWritings : MyStrings.viewOtherUsersWriting),
      body: SafeArea(
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
                                text: MyStrings.noWritings,
                                color: MyColors.purple,
                                size: 20,
                                isBold: true,
                              ),
                            )
                            : ListView.builder(
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
            Obx(() => Offstage(
                  offstage: !controller.isLoading.value,
                  child: Stack(
                    children: const [
                      Opacity(opacity: 0.5, child: ModalBarrier(dismissible: false, color: Colors.black)),
                      Center(
                        child: CircularProgressIndicator(),
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
