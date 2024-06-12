import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/favorite_icon.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_date_format.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/responsive_size.dart';
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
  late final WritingController controller;
  final scrollController = ScrollController();
  final docsLimit = 10;
  List<String> statusList = [tr('writingStatus0'), tr('writingStatus1'), tr('writingStatus2'), tr('writingStatus3')];
  List<Color> statusColors = [MyColors.mustard, MyColors.purple, MyColors.green, MyColors.red];
  DocumentSnapshot? lastSnapshot;
  bool isLoaded = false;
  bool hasMore = true;
  late ResponsiveSize rs;
  bool? hasBackBtn = Get.arguments;

  loadWritings({bool isContinue = false}) async {
    final ref = FirebaseFirestore.instance.collection('Writings');
    Query query = ref.where('userId', isEqualTo: User().id).orderBy('dateWriting', descending: true).limit(docsLimit);

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
      padding: EdgeInsets.symmetric(vertical: tag == 'A' ? rs.getSize(10) : 0),
      child: Row(
        children: [
          MyWidget().getTextWidget(rs, text: '$tag. ', isBold: true, color: Theme.of(context).secondaryHeaderColor),
          SizedBox(width: rs.getSize(15)),
          Expanded(
            child: HtmlWidget(
              content,
              textStyle: TextStyle(
                fontFamily: 'KoreanFont',
                fontSize: rs.getSize(15),
                height: 1.5,
                color: Theme.of(context).secondaryHeaderColor
              ),
            ),
          ),
          Visibility(
            visible: writing.status == 1 && tag.contains('C') || writing.status == 2 && tag.contains('A'),
            child: Obx(() =>
                FavoriteIcon().getFlashcardIcon(context, rs, controller: controller, itemId: writing.id, front: extractedText)),
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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                MyWidget().showDialog(context, rs, content: tr('wantRemoveWriting'), yesFn: () {
                  String id = writing.id;
                  Database().deleteDoc(collection: 'Writings', docId: id).then((value) {
                    writings.removeWhere((element) => element.id == id);
                    controller.update();
                  });
                });
              },
              child: Padding(
                padding: EdgeInsets.all(rs.getSize(5)),
                child: Icon(
                  Icons.remove_circle_outline_rounded,
                  size: rs.getSize(15),
                  color: Theme.of(context).focusColor,
                ),
              ),
            )
          ],
        ),
        MyWidget().getRoundedContainer(
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MyWidget().getRoundedContainer(
                      widget: MyWidget().getTextWidget(rs, text: statusList[status], color: Theme.of(context).cardColor, size: 13),
                      radius: 20,
                      padding: EdgeInsets.symmetric(vertical: rs.getSize(2), horizontal: rs.getSize(10)),
                      bgColor: statusColors[status]),
                  SizedBox(width: rs.getSize(10)),
                  Expanded(
                      child: MyWidget().getTextWidget(rs,
                          text: 'Lv.${(writing.questionLevel + 1).toString()}', color: Theme.of(context).disabledColor)),
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.keyboard_double_arrow_left_rounded, size: rs.getSize(13), color: Theme.of(context).disabledColor),
                          const SizedBox(width: 5),
                          MyWidget().getTextWidget(rs,
                              text: MyDateFormat().getDateFormat(writing.dateWriting), size: 12, color: Theme.of(context).disabledColor),
                        ],
                      ),
                      writing.dateReply != null
                          ? Row(
                              children: [
                                Icon(Icons.keyboard_double_arrow_right_rounded,
                                    size: rs.getSize(13), color: Theme.of(context).disabledColor),
                                const SizedBox(width: 5),
                                MyWidget().getTextWidget(rs,
                                    text: MyDateFormat().getDateFormat(writing.dateReply!),
                                    size: 12,
                                    color: Theme.of(context).disabledColor),
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
              const Divider(),
              Visibility(
                visible: writing.comments != null,
                child: Column(
                  children: [
                    MyWidget().getTextWidget(rs, text: 'Comments', isBold: true, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 10),
                    MyWidget().getTextWidget(rs, text: writing.comments, color: Theme.of(context).primaryColor),
                  ],
                ),
              )
            ],
          ),
        bgColor: Theme.of(context).cardColor),
      ],
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    if(Get.isRegistered<WritingController>()) {
      controller = Get.find<WritingController>();
    } else {
      controller = Get.put(WritingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    rs = ResponsiveSize(context);
    lastSnapshot = null;
    if (writings.isEmpty) {
      // TextField 로 인한 rebuild 방지용
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
        appBar: hasBackBtn != null && hasBackBtn! ? MyWidget().getAppbar(context, rs, title: '') : null,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: rs.getSize(20), top: rs.getSize(15)),
              child: MyWidget()
                  .getTextWidget(rs, text: tr('myWritings'), color: Theme.of(context).primaryColor, isBold: true, size: 18),
            ),
            Expanded(
              child: Stack(
                children: [
                  GetBuilder<WritingController>(
                    builder: (_) {
                      return Padding(
                        padding: EdgeInsets.all(rs.getSize(15)),
                        child: Column(
                          children: [
                            Expanded(
                              child: isLoaded && writings.isEmpty
                                  ? Center(
                                      child: MyWidget().getTextWidget(
                                        rs,
                                        text: tr('noMyWritings'),
                                        isTextAlignCenter: true,
                                        size: 18,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: writings.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Padding(
                                          padding: EdgeInsets.only(bottom: rs.getSize(30)),
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
                        child: const Stack(
                          children: [
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
    );
  }
}
