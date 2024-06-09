import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/ads_controller.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/favorite_icon.dart';
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
  final toggles = ['My', 'more'];
  final cardBorderRadius = 8.0;
  int selectedToggle = 0;
  final KO = 'ko';
  final My_READINGS = 'Users/${User().id}/Readings';
  final READING_TITLES = 'ReadingTitles';
  final CATEGORY = 'category';
  final ORDER_ID = 'orderId';
  final IS_FREE = 'isFree';
  final IS_RELEASED = 'isReleased';
  final DATE = 'date';
  String fo = User().language;
  final controller = Get.find<ReadingController>();
  bool isBasicUser = User().status == 0 || User().status == 1;
  late Query query;
  bool shouldLoad = true; // TextField 로 인한 rebuild 방지용
  late ResponsiveSize rs;

  Widget getListItem({required ReadingTitle readingTitle}) {
    return Theme(
      data: Theme.of(context).copyWith(highlightColor: MyColors.navyLight),
      child: Column(
        children: [
          selectedToggle == 0 ?
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  MyWidget().showDialog(context, rs, content: tr('wantRemoveReading'), yesFn: () {
                    String id = readingTitle.id;
                    Database().deleteDoc(collection: My_READINGS, docId: id).then((value) {
                      controller.readingTitles.removeWhere((element) => element.id == id);
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
          ) : const SizedBox.shrink(),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cardBorderRadius),
            ),
            color: Theme.of(context).cardColor,
            child: InkWell(
              onTap: (){
                if (isBasicUser) {
                  if(!readingTitle.isFree) {
                    MyWidget().showDialog(context, rs, content: tr('wantUnlockReading'), yesFn: () {
                      Get.toNamed(MyStrings.routePremiumMain);
                    }, hasPremiumTag: true, hasNoBtn: false, yesText: tr('explorePremium'));
                  } else {
                    MyWidget().showDialog(context, rs, content: tr('watchRewardAdReading'), yesFn: () {
                      AdsController().showRewardAd();
                      FirebaseAnalytics.instance.logSelectContent(contentType: 'reading', itemId: readingTitle.title[KO]);
                      Get.toNamed(MyStrings.routeReadingFrame, arguments: readingTitle.id);
                    }, hasNoBtn: false, hasTextBtn: true);
                  }
                } else {
                  Get.toNamed(MyStrings.routeReadingFrame, arguments: readingTitle.id);
                }
              },
              child: Padding(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Transform.scale(
                                    alignment: Alignment.bottomLeft,
                                    scale: 0.8,
                                    child: Image.asset('assets/images/${rockets[readingTitle.level]}.png'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Obx(
                                      () => controller.isCompleted[readingTitle.id]
                                          ? Icon(
                                              Icons.check_circle,
                                              color: Theme.of(context).highlightColor,
                                              size: rs.getSize(20),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ),
                                  readingTitle.tag != null && readingTitle.tag.toString().isNotEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: MyWidget().getRoundedContainer(
                                              widget: MyWidget().getTextWidget(rs,
                                                  text: readingTitle.tag, color: Theme.of(context).focusColor, size: 13),
                                              bgColor: Theme.of(context).shadowColor,
                                              radius: 30,
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3)),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                              (isBasicUser && !readingTitle.isFree)
                                  ? Icon(CupertinoIcons.lock_fill, color: Theme.of(context).disabledColor, size: 15)
                                  : const SizedBox.shrink(),
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getReading(0, true);
  }

  getReading(int st, bool sl) async {
   selectedToggle = st;
   shouldLoad = sl;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (selectedToggle == 0) {
      query = firestore.collection(My_READINGS).orderBy(DATE, descending: true);
    } else {
      query = firestore.collection(READING_TITLES).where('category', isNotEqualTo: 'Lesson');
    }

    if (shouldLoad) {
      controller.readingTitles = [];
      Map<String, bool> isCompletedMap = {};
      await Database().getDocs(query: query).then((snapshots) {
        for (dynamic snapshot in snapshots) {
          ReadingTitle title = ReadingTitle.fromJson(snapshot.data() as Map<String, dynamic>);
          controller.readingTitles.add(title);
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
        body: Padding(
          padding: EdgeInsets.all(rs.getSize(10)),
          child: Column(
            children: [
              SizedBox(
                height: rs.getSize(30),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: toggles.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            getReading(index, true);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedToggle == index ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: rs.getSize(15), vertical: rs.getSize(3)),
                          child: MyWidget().getTextWidget(
                            rs,
                            text: toggles[index],
                            color: selectedToggle == index ? Theme.of(context).cardColor : Theme.of(context).primaryColorDark,
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
                  : GetBuilder<ReadingController>(
                    builder: (_){
                      return Expanded(
                        child: controller.readingTitles.isEmpty
                            ? selectedToggle == 0 ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FavoriteIcon().getIcon(context, rs),
                            SizedBox(height: rs.getSize(10)),
                            MyWidget().getTextWidget(rs,
                                text: tr('noMyReadings'), isTextAlignCenter: true, size: 18),
                            SizedBox(height: rs.getSize(50)),
                          ],
                        ) : Center(
                            child: MyWidget().getTextWidget(rs,
                                text: tr('noReadingTitle'),
                                color: Theme.of(context).primaryColor,
                                size: rs.getSize(20),
                                isTextAlignCenter: true))
                            : ListView.builder(
                          itemCount: controller.readingTitles.length,
                          itemBuilder: (BuildContext context, int index) {
                            ReadingTitle readingTitle = controller.readingTitles[index];
                            return getListItem(readingTitle: readingTitle);
                          },
                        ),
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
