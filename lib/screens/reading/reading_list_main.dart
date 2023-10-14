import 'dart:convert';
import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/screens/reading/reading_controller.dart';
import 'package:podo/screens/reading/reading_title.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class ReadingListMain extends StatefulWidget {
  ReadingListMain({Key? key}) : super(key: key);

  @override
  State<ReadingListMain> createState() => _ReadingListMainState();
}

class _ReadingListMainState extends State<ReadingListMain> {
  final rockets = ['rocket1', 'rocket2', 'rocket3'];
  final categories = ['All', 'About Korea'];
  final cardBorderRadius = 8.0;
  int selectedCategory = 0;
  final KO = 'ko';
  final READING_TITLES = 'ReadingTitles';
  final CATEGORY = 'category';
  final ORDER_ID = 'orderId';
  final IS_FREE = 'isFree';
  final IS_RELEASED = 'isReleased';
  String fo = User().language;
  late List<ReadingTitle> readingTitles;
  final controller = Get.put(ReadingController());
  bool isBasicUser = User().status == 1;
  late Query query;
  bool shouldLoad = true; // TextField 로 인한 rebuild 방지용
  late ResponsiveSize rs;

  Widget getListItem({required ReadingTitle readingTitle}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardBorderRadius),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: (isBasicUser && !readingTitle.isFree)
            ? null
            : () {
                FirebaseAnalytics.instance.logSelectContent(contentType: 'reading', itemId: readingTitle.id);
                Get.toNamed(MyStrings.routeReadingFrame, arguments: readingTitle);
              },
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(rs.getSize(10)),
              child: Row(
                children: [
                  readingTitle.image != null && readingTitle.image!.isNotEmpty
                      ? Hero(
                          tag: 'readingImage:${readingTitle.id}',
                          child: Image.memory(base64Decode(readingTitle.image!),
                              gaplessPlayback: true, height: rs.getSize(80), width: rs.getSize(80)))
                      : const SizedBox.shrink(),
                  SizedBox(width: rs.getSize(20)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Transform.scale(
                              alignment: Alignment.bottomLeft,
                              scale: 0.8,
                              child: Image.asset('assets/images/${rockets[readingTitle.level]}.png'),
                            ),
                            SizedBox(width: rs.getSize(10)),
                            Obx(
                              () => controller.isCompleted[readingTitle.id]
                                  ? Icon(
                                      Icons.check_circle,
                                      color: MyColors.green,
                                      size: rs.getSize(20),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                        SizedBox(height: rs.getSize(10)),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: MyWidget().getTextWidget(
                            rs,
                            text: readingTitle.title[KO] ?? '',
                            size: 20,
                            color: MyColors.navy,
                          ),
                        ),
                        SizedBox(height: rs.getSize(10)),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: MyWidget().getTextWidget(
                            rs,
                            text: readingTitle.title[fo] ?? '',
                            color: MyColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            readingTitle.tag.isNotEmpty
                ? Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                        decoration: BoxDecoration(
                          color: MyColors.pink,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(cardBorderRadius),
                            bottomLeft: Radius.circular(cardBorderRadius),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: rs.getSize(10), vertical: rs.getSize(3)),
                        child: Text(readingTitle.tag,
                            style: TextStyle(color: MyColors.red, fontSize: rs.getSize(15)))),
                  )
                : const SizedBox.shrink(),
            (isBasicUser && !readingTitle.isFree)
                ? Positioned.fill(
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(MyStrings.routePremiumMain);
                      },
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: Blur(
                              blur: 1.0,
                              child: SizedBox.shrink(),
                            ),
                          ),
                          Center(
                            child: Icon(
                              FontAwesomeIcons.lock,
                              color: MyColors.grey,
                              size: rs.getSize(30),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    selectedCategory = 0;
    getReading();
  }



  getReading() async {
    query = FirebaseFirestore.instance.collection(READING_TITLES).where(IS_RELEASED, isEqualTo: true);
    if (selectedCategory == 0) {
      query = query.orderBy(ORDER_ID, descending: true);
    } else {
      query = query.where(CATEGORY, isEqualTo: categories[selectedCategory]).orderBy(ORDER_ID, descending: true);
    }

    if (User().status == 0) {
      query = query.where(IS_FREE, isEqualTo: true);
    }

    if (shouldLoad) {
      readingTitles = [];
      Map<String, bool> isCompletedMap = {};
      await Database().getDocs(query: query).then((snapshots) {
        for (dynamic snapshot in snapshots) {
          ReadingTitle title = ReadingTitle.fromJson(snapshot.data() as Map<String, dynamic>);
          readingTitles.add(title);
          isCompletedMap[title.id] = LocalStorage().hasHistory(itemId: title.id);
          controller.isCompleted.value = isCompletedMap.obs;
        }
        setState(() {
          shouldLoad = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    rs = ResponsiveSize(context);
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(rs.getSize(10)),
            child: Column(
              children: [
                SizedBox(
                  height: rs.getSize(30),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              shouldLoad = true;
                              selectedCategory = index;
                              getReading();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedCategory == index ? MyColors.purple : Colors.white,
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: rs.getSize(15), vertical: rs.getSize(3)),
                            child: MyWidget().getTextWidget(
                              rs,
                              text: categories[index],
                              color: selectedCategory == index ? Colors.white : MyColors.navy,
                              size: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: rs.getSize(10)),
                shouldLoad
                    ? const Expanded(child: Center(child: CircularProgressIndicator()))
                    : Expanded(
                        child: readingTitles.isEmpty
                            ? Center(
                                child: MyWidget().getTextWidget(rs,
                                    text: tr('noReadingTitle'),
                                    color: MyColors.purple,
                                    size: rs.getSize(20),
                                    isTextAlignCenter: true))
                            : ListView.builder(
                                itemCount: readingTitles.length,
                                itemBuilder: (BuildContext context, int index) {
                                  ReadingTitle readingTitle = readingTitles[index];
                                  return getListItem(readingTitle: readingTitle);
                                },
                              ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
