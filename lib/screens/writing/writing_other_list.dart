import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:podo/common/database.dart';
import 'package:podo/common/favorite_icon.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/screens/writing/writing.dart';
import 'package:podo/screens/writing/writing_controller.dart';
import 'package:podo/values/my_colors.dart';

class WritingOtherList extends StatelessWidget {
  WritingOtherList({Key? key}) : super(key: key);

  List<Writing> writings = [];
  final controller = Get.find<WritingController>();
  final scrollController = ScrollController();
  final docsLimit = 20;
  String? questionId = Get.arguments;
  bool isLoaded = false;
  late ResponsiveSize rs;

  loadWritings({bool isContinue = false}) async {
    final ref = FirebaseFirestore.instance.collection('Writings');
    Query query = ref
        .where('questionId', isEqualTo: questionId!)
        .where('userId', isNotEqualTo: User().id)
        .where('status', whereIn: [1, 2]).limit(docsLimit);

    controller.isLoading.value = true;
    List<dynamic> snapshots = await Database().getDocs(query: query);
    controller.isLoading.value = false;

    if (snapshots.isNotEmpty) {
      for (dynamic snapshot in snapshots) {
        Writing writing = Writing.fromJson(snapshot.data() as Map<String, dynamic>);
        writings.add(writing);
        controller.hasFlashcard[writing.id] = LocalStorage().hasFlashcard(itemId: writing.id);
      }
    }
    isLoaded = true;
    controller.update();
  }

  Widget getItem(BuildContext context, Writing writing) {
    int status = writing.status;

    String content = '';
    if (status == 1) {
      content = writing.correction;
    } else if (status == 2) {
      content = writing.userWriting;
    }
    String extractedText = htmlParser.parse(content).body!.text;

    return Row(
      children: [
        Expanded(child: MyWidget().getTextWidget(rs, text: extractedText, color: Theme.of(context).secondaryHeaderColor)),
        Obx(() => FavoriteIcon().getFlashcardIcon(context, rs, controller: controller, itemId: writing.id, front: extractedText)),
      ],
    );
  }

  Widget getWritingList(BuildContext context, int index) {
    Writing writing = writings[index];

    return MyWidget().getRoundedContainer(
      widget: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MyWidget().getTextWidget(rs,
                  text: writing.userName == null || writing.userName!.isEmpty ? tr('unNamed') : writing.userName,
                  color: Theme.of(context).disabledColor),
            ],
          ),
          const Divider(),
          getItem(context, writing)
        ],
      ), bgColor: Theme.of(context).cardColor
    );
  }

  @override
  Widget build(BuildContext context) {
    rs = ResponsiveSize(context);
    if (writings.isEmpty) {
      // TextField 로 인한 rebuild 방지용
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadWritings();
      });
    }

    return Scaffold(
      appBar: MyWidget().getAppbar(context, rs, title: tr('viewOtherUsersWriting')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 15),
            child:
                MyWidget().getTextWidget(rs, text: tr('myWritings'), color: Theme.of(context).primaryColor, isBold: true, size: 18),
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
                                      rs,
                                      text: tr('noWritings'),
                                      isTextAlignCenter: true,
                                      size: 18,
                                      color: Theme.of(context).secondaryHeaderColor
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: writings.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 30),
                                        child: getWritingList(context, index),
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
                        children: [
                          Opacity(opacity: 0.3, child: ModalBarrier(dismissible: false, color: Theme.of(context).secondaryHeaderColor)),
                          const Center(
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
    );
  }
}
