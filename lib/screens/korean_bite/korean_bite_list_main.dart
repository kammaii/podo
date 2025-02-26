import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podo/common/ads_controller.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/korean_bite/korean_bite.dart';
import 'package:podo/screens/korean_bite/korean_bite_controller.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class KoreanBiteListMain extends StatefulWidget {
  const KoreanBiteListMain({super.key});

  @override
  State<KoreanBiteListMain> createState() => _KoreanBiteListMainState();
}

class _KoreanBiteListMainState extends State<KoreanBiteListMain> {
  final toggles = ['All'];
  int selectedToggle = 0;
  final BITES_COLLECTION = 'KoreanBites';
  final READING_TITLES = 'ReadingTitles';
  final DATE = 'date';
  List<KoreanBite> koreanBites = [];
  KoreanBiteController controller = Get.isRegistered<KoreanBiteController>()
      ? Get.find<KoreanBiteController>()
      : Get.put(KoreanBiteController());
  late ResponsiveSize rs;
  final cardBorderRadius = 8.0;
  bool isBasicUser = User().status == 0 || User().status == 1;
  String fo = User().language;
  final KO = 'ko';
  bool _isLoading = false;
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  final int _limit = 10;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  Map<String, bool> isCompletedMap = {};
  KoreanBite? shouldOpenKoreanBite = Get.arguments;

  @override
  void initState() {
    super.initState();
    fetchKoreanBites();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        fetchKoreanBites();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('SHOULD OPEN: $shouldOpenKoreanBite');
      if (shouldOpenKoreanBite != null) {
        Get.toNamed(MyStrings.routeKoreanBiteFrame, arguments: shouldOpenKoreanBite);
        shouldOpenKoreanBite = null;
      }
    });
  }

  fetchKoreanBites() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    Query query = _firestore
        .collection(BITES_COLLECTION)
        .where('isReleased', isEqualTo: true)
        .orderBy(DATE, descending: true)
        .limit(_limit);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    await Database().getDocs(query: query).then((snapshots) {
      if (snapshots.isNotEmpty) {
        _lastDoc = snapshots.last;
        for (dynamic snapshot in snapshots) {
          KoreanBite bite = KoreanBite.fromJson(snapshot.data() as Map<String, dynamic>);
          koreanBites.add(bite);
          isCompletedMap[bite.id] = LocalStorage().hasHistory(itemId: bite.id);
          controller.isCompleted.value = isCompletedMap.obs;
        }
        setState(() {
          _isLoading = false;
          if (snapshots.length < _limit) {
            _hasMore = false;
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
      }
    });
  }

  Widget getListItem({required int index, required KoreanBite koreanBite}) {
    String tags = koreanBite.tags.map((e) => '#$e').join(' ');
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardBorderRadius),
      ),
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: () {
          if (isBasicUser) {
            MyWidget().showDialog(context, rs,
                content: tr('watchRewardAdKoreanBite'),
                yesFn: () async {
                  AdsController().showRewardAd();
                  Get.toNamed(MyStrings.routeKoreanBiteFrame, arguments: koreanBite);
                },
                hasNoBtn: false,
                textBtnText: tr('explorePremium'),
                textBtnFn: () async {
                  Get.toNamed(MyStrings.routePremiumMain);
                });
          } else {
            Get.toNamed(MyStrings.routeKoreanBiteFrame, arguments: koreanBite);
          }
        },
        child: Padding(
          padding: EdgeInsets.all(rs.getSize(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyWidget().getTextWidget(rs,
                      text: '${koreanBite.orderId}. $tags', color: Theme.of(context).primaryColorDark),
                  Obx(
                    () => controller.isCompleted[koreanBite.id]
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? MyColors.darkPurple
                                : MyColors.green,
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
                  text: koreanBite.title[KO],
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: rs.getSize(10)),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: MyWidget().getTextWidget(
                  rs,
                  text: koreanBite.title[fo] ?? '',
                  color: MyColors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    rs = ResponsiveSize(context);
    List<Widget>? actions;
    if (!User().fcmPermission) {
      actions = [
        IconButton(
            onPressed: () {
              MyWidget().showDialog(context, rs, content: tr('enable_notification'), yesFn: () {
                openAppSettings();
              }, hasNoBtn: false);
            },
            icon: Icon(
              Icons.lightbulb,
              color: Colors.yellow,
            ))
      ];
    }
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: Scaffold(
        appBar: MyWidget().getAppbar(context, rs, title: tr('korean_bites'), actions: actions),
        body: Padding(
          padding: EdgeInsets.all(rs.getSize(10)),
          child: GetBuilder<KoreanBiteController>(
            builder: (_) {
              return koreanBites.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: koreanBites.length + 1, // 로딩 UI 포함
                      itemBuilder: (BuildContext context, int index) {
                        if (index < koreanBites.length) {
                          KoreanBite koreanBite = koreanBites[index];
                          int koreanBiteIndex = koreanBites.length - index;
                          return getListItem(index: koreanBiteIndex, koreanBite: koreanBite);
                        } else {
                          return _isLoading ? Center(child: CircularProgressIndicator()) : const SizedBox.shrink();
                        }
                      },
                    );
            },
          ),
        ),
      ),
    );
  }
}
