import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/profile/history.dart';
import 'package:podo/screens/profile/user.dart';
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
  final categories = ['All', 'About Korea', 'Entertainment', 'Daily life', 'Story book'];
  final cardBorderRadius = 8.0;
  int selectedCategory = 0;
  final KO = 'ko';
  final READING_TITLES = 'ReadingTitles';
  final CATEGORY = 'category';
  final ORDER_ID = 'orderId';
  String fo = User().language;
  late List<ReadingTitle> readingTitles;

  Widget getListItem({required ReadingTitle readingTitle}) {
    bool isCompleted = LocalStorage().hasHistory(itemId: readingTitle.id);

    return Stack(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardBorderRadius),
          ),
          color: Colors.white,
          child: InkWell(
            onTap: () {
              Get.toNamed(MyStrings.routeReadingFrame, arguments: readingTitle);
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Hero(
                      tag: 'readingImage:${readingTitle.id}',
                      child: Image.asset('assets/images/course_hangul.png'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
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
                          isCompleted
                              ? const Icon(
                                  Icons.check_circle,
                                  color: MyColors.green,
                                  size: 20,
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      MyWidget().getTextWidget(
                        text: readingTitle.title[KO] ?? '',
                        size: 20,
                        color: MyColors.navy,
                      ),
                      const SizedBox(height: 10),
                      MyWidget().getTextWidget(
                        text: readingTitle.title[fo] ?? '',
                        color: MyColors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        readingTitle.tag.isNotEmpty
            ? Positioned(
                top: 5,
                right: 4,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference ref = FirebaseFirestore.instance.collection(READING_TITLES);
    Query query;
    if (selectedCategory == 0) {
      query = ref.orderBy(ORDER_ID, descending: true);
    } else {
      query = ref.where(CATEGORY, isEqualTo: categories[selectedCategory]).orderBy(ORDER_ID, descending: true);
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
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
                      for (dynamic snapshot in snapshot.data) {
                        readingTitles.add(ReadingTitle.fromJson(snapshot.data() as Map<String, dynamic>));
                      }
                      if (readingTitles.isEmpty) {
                        return Center(
                            child: MyWidget().getTextWidget(
                                text: MyStrings.noReadingTitle,
                                color: MyColors.purple,
                                size: 20,
                                isTextAlignCenter: true));
                      } else {
                        return ListView.builder(
                          itemCount: readingTitles.length,
                          itemBuilder: (BuildContext context, int index) {
                            ReadingTitle readingTitle = readingTitles[index];
                            return getListItem(readingTitle: readingTitle);
                          },
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Text('에러: ${snapshot.error}');
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
