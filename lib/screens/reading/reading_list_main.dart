import 'dart:convert';

import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
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
  late List<String> categories;
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
  bool hasCategory = false;
  late Query query;

  Widget getListItem({required ReadingTitle readingTitle}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardBorderRadius),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: (isBasicUser && !readingTitle.isFree)
            ? null
            : () async {
                //todo: await FirebaseAnalytics.instance.logSelectContent(contentType: 'reading', itemId: readingTitle.id);
                Get.toNamed(MyStrings.routeReadingFrame, arguments: readingTitle);
              },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  readingTitle.image != null
                      ? Hero(
                          tag: 'readingImage:${readingTitle.id}',
                          child: Image.memory(base64Decode(readingTitle.image!),
                              gaplessPlayback: true, height: 80, width: 80))
                      : const SizedBox.shrink(),
                  const SizedBox(width: 20),
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
                            const SizedBox(width: 10),
                            Obx(
                              () => controller.isCompleted[readingTitle.id]
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: MyColors.green,
                                      size: 20,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: MyWidget().getTextWidget(
                            text: readingTitle.title[KO] ?? '',
                            size: 20,
                            color: MyColors.navy,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: MyWidget().getTextWidget(
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        child: Text(readingTitle.tag, style: const TextStyle(color: MyColors.red))),
                  )
                : const SizedBox.shrink(),
            (isBasicUser && !readingTitle.isFree)
                ? Positioned.fill(
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(MyStrings.routePremiumMain);
                      },
                      child: Stack(
                        children: const [
                          Positioned.fill(
                            child: Blur(
                              blur: 1.0,
                              child: SizedBox.shrink(),
                            ),
                          ),
                          Center(
                            child: Icon(
                              FontAwesomeIcons.lock,
                              color: MyColors.grey,
                              size: 30,
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
    setQuery();
    Database().getDocs(query: query).then((snapshots) {
      categories = [];
      Map<String, int> categoryCountMap = {};
      for (dynamic snapshot in snapshots) {
        ReadingTitle title = ReadingTitle.fromJson(snapshot.data() as Map<String, dynamic>);
        final category = title.category;
        categoryCountMap[category] = (categoryCountMap[category] ?? 0) + 1;
      }
      categories = categoryCountMap.keys.toList();
      categories.sort((a, b) => categoryCountMap[b]!.compareTo(categoryCountMap[a]!));
      categories.insert(0, 'All');
      setState(() {
        hasCategory = true;
      });
    });
  }

  void setQuery() {
    query = FirebaseFirestore.instance.collection(READING_TITLES).where(IS_RELEASED, isEqualTo: true);
    if (selectedCategory == 0) {
      query = query.orderBy(ORDER_ID, descending: true);
    } else {
      query = query.where(CATEGORY, isEqualTo: categories[selectedCategory]).orderBy(ORDER_ID, descending: true);
    }

    if (User().status == 0) {
      query = query.where(IS_FREE, isEqualTo: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: hasCategory
                ? Column(
                    children: [
                      SizedBox(
                        height: 30,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCategory = index;
                                    setQuery();
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedCategory == index ? MyColors.purple : Colors.white,
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                                  child: MyWidget().getTextWidget(
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
                      const SizedBox(height: 20),
                      Expanded(
                        child: FutureBuilder(
                          future: Database().getDocs(query: query),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                              readingTitles = [];
                              Map<String, bool> isCompletedMap = {};
                              for (dynamic snapshot in snapshot.data) {
                                ReadingTitle title = ReadingTitle.fromJson(snapshot.data() as Map<String, dynamic>);
                                readingTitles.add(title);
                                isCompletedMap[title.id] = LocalStorage().hasHistory(itemId: title.id);
                              }
                              controller.isCompleted.value = isCompletedMap.obs;

                              return readingTitles.isEmpty
                                  ? Center(
                                      child: MyWidget().getTextWidget(
                                          text: tr('noReadingTitle'),
                                          color: MyColors.purple,
                                          size: 20,
                                          isTextAlignCenter: true))
                                  : ListView.builder(
                                      itemCount: readingTitles.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        ReadingTitle readingTitle = readingTitles[index];
                                        return getListItem(readingTitle: readingTitle);
                                      },
                                    );
                            } else {
                              return const Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
