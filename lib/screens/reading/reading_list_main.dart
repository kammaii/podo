import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/reading/reading.dart';
import 'package:podo/screens/reading/reading_frame.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class ReadingListMain extends StatefulWidget {
  ReadingListMain({Key? key}) : super(key: key);

  @override
  State<ReadingListMain> createState() => _ReadingListMainState();
}

class _ReadingListMainState extends State<ReadingListMain> {
  final rockets = ['rocket1', 'rocket2', 'rocket3'];
  final categories = ['culture', 'food', 'travel', 'story book'];
  final cardBorderRadius = 8.0;
  int selectedCategory = 0;
  final KO = 'ko';
  final READINGS = 'Readings';
  final CATEGORY = 'category';
  final ORDER_ID = 'orderId';
  String fo = 'en'; //todo: UserInfo 의 language 로 설정하기
  late List<Reading> readings;
  String setLanguage = 'en'; //todo: 기기 설정에 따라 바뀌게 하기

  Widget getListItem({required Reading reading}) {
    return Stack(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardBorderRadius),
          ),
          color: Colors.white,
          child: InkWell(
            onTap: () {
              Get.to(const ReadingFrame(), arguments: reading);
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Hero(
                      tag: 'readingImage:${reading.id}',
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
                            child: Image.asset('assets/images/${rockets[reading.level]}.png'),
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: MyColors.green,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      MyWidget().getTextWidget(
                        text: reading.title[KO] ?? '',
                        size: 20,
                        color: MyColors.navy,
                      ),
                      const SizedBox(height: 10),
                      MyWidget().getTextWidget(
                        text: reading.title[fo] ?? '',
                        color: MyColors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        reading.tag.isNotEmpty
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
                    child: Text(reading.tag, style: const TextStyle(color: MyColors.red))),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
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
                            color: selectedCategory == index ? MyColors.purple : MyColors.navy,
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                          child: MyWidget().getTextWidget(text: categories[index], color: Colors.white, size: 17),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder(
                  future: Database().getDocs(
                      collection: READINGS,
                      field: CATEGORY,
                      equalTo: categories[selectedCategory],
                      orderBy: ORDER_ID,
                      descending: false),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                      readings = [];
                      for (dynamic snapshot in snapshot.data) {
                        readings.add(Reading.fromJson(snapshot));
                      }
                      if (readings.isEmpty) {
                        return Center(
                            child: MyWidget().getTextWidget(
                                text: MyStrings.noReading,
                                color: MyColors.purple,
                                size: 20,
                                isTextAlignCenter: true));
                      } else {
                        return ListView.builder(
                          itemCount: readings.length,
                          itemBuilder: (BuildContext context, int index) {
                            Reading reading = readings[index];
                            return getListItem(reading: reading);
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
