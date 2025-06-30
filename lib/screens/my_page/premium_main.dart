import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;


class PremiumMain extends StatefulWidget {
  PremiumMain({Key? key}) : super(key: key);

  @override
  State<PremiumMain> createState() => _PremiumMainState();
}

class _PremiumMainState extends State<PremiumMain> {
  late List<bool> selector;
  bool isPurchasing = false;
  late ResponsiveSize rs;
  final PURCHASE_TRACE = 'purchase_trace';
  final PURCHASE_STATUS = 'purchase_status';
  final SUCCESS = 'success';
  final FAILED = 'failed';
  final ERROR_CODE = 'errorCode';
  int? trialLeftDate = Get.arguments;
  String? msgForTrial;
  late Timer timer;
  StreamController<String> streamController = StreamController();
  final ScrollController scrollController = ScrollController();
  Package? package;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  bool isPodoStoryActive = false;
  int selectedPlan = 1;
  late Future<Offerings> offerings;
  String plan = 'Six Months';
  Offering? sixMonthsOffering;

  @override
  void initState() {
    super.initState();
    analytics.logViewItem(parameters: {'item': 'Premium'});
    if (trialLeftDate != null) {
      if (trialLeftDate! > 3) {
        msgForTrial = tr('msgForTrial1');
      } else if (trialLeftDate! <= 3) {
        msgForTrial = tr('msgForTrial2');
      }
    }
    offerings = Purchases.getOfferings();
    // 구독하지 마세요 Dialog
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   if (trialLeftDate == null && User().showPremiumDialog) {
    //     Get.dialog(
    //         AlertDialog(
    //           title:
    //               Center(child: Image.asset('assets/images/podo.png', width: rs.getSize(50), height: rs.getSize(50))),
    //           content: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             children: [
    //               MyWidget().getTextWidget(rs,
    //                   text: tr('premiumDialog1'), color: Theme.of(context).primaryColor, isBold: true, size: 18),
    //               SizedBox(height: rs.getSize(10)),
    //               MyWidget().getTextWidget(rs,
    //                   text: tr('premiumDialog2'),
    //                   isTextAlignCenter: true,
    //                   color: Theme.of(context).secondaryHeaderColor),
    //               SizedBox(height: rs.getSize(10)),
    //               MyWidget().getTextWidget(rs,
    //                   text: tr('premiumDialog3'),
    //                   isTextAlignCenter: true,
    //                   color: Theme.of(context).primaryColor,
    //                   size: 13),
    //             ],
    //           ),
    //           backgroundColor: Theme.of(context).cardColor,
    //           actionsAlignment: MainAxisAlignment.center,
    //           actionsPadding: EdgeInsets.only(
    //               left: rs.getSize(20), right: rs.getSize(20), bottom: rs.getSize(20), top: rs.getSize(10)),
    //           actions: [
    //             ElevatedButton(
    //               style: ElevatedButton.styleFrom(
    //                   shape: RoundedRectangleBorder(
    //                     borderRadius: BorderRadius.circular(30),
    //                   ),
    //                   side: BorderSide(color: Theme.of(context).canvasColor, width: 1),
    //                   backgroundColor: Theme.of(context).canvasColor),
    //               onPressed: () {
    //                 User().showPremiumDialog = false;
    //                 Get.back();
    //               },
    //               child: Padding(
    //                 padding: EdgeInsets.symmetric(vertical: rs.getSize(13), horizontal: rs.getSize(20)),
    //                 child: Text(tr('premiumDialog4'),
    //                     style: TextStyle(color: Theme.of(context).cardColor, fontSize: rs.getSize(15))),
    //               ),
    //             ),
    //           ],
    //         ),
    //         barrierDismissible: false);
    //   }
    // });
  }

  Stream<String>? getTimeLeftStream() {
    if (User().trialEnd == null) return null;
    Duration calTimeLeft() {
      DateTime now = DateTime.now();
      Duration leftTime = User().trialEnd!.difference(now);
      return leftTime.isNegative ? Duration.zero : leftTime;
    }

    void updateText() {
      if (!mounted || streamController.isClosed) {
        return;
      }
      Duration leftTime = calTimeLeft();
      String day = leftTime.inDays != 0 ? '${leftTime.inDays.toString().padLeft(2, '0')} d' : '';
      String hour = '${(leftTime.inHours % 24).toString().padLeft(2, '0')} h';
      String min = '${(leftTime.inMinutes % 60).toString().padLeft(2, '0')} m';
      String sec = '${(leftTime.inSeconds % 60).toString().padLeft(2, '0')} s';
      streamController.add('$day $hour $min $sec');

      if (leftTime == Duration.zero) {
        timer.cancel();
        streamController.close();
      }
    }

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      updateText();
    });

    void startTimer() {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        updateText();
      });
    }

    streamController = StreamController<String>(onListen: () {
      updateText();
      startTimer();
    }, onCancel: () {
      timer.cancel();
    });

    return streamController.stream;
  }

  @override
  void dispose() {
    if (msgForTrial != null) {
      timer.cancel();
      streamController.close();
    }
    scrollController.dispose();
    super.dispose();
  }

  DataColumn getDataColumn(String label) {
    return DataColumn(
      label: Expanded(
        child: Center(child: MyWidget().getTextWidget(rs, text: label)),
      ),
    );
  }

  DataRow getDataRow(String title, Widget basic, Widget premium, {bool isLimited = false}) {
    return DataRow(cells: <DataCell>[
      DataCell(MyWidget().getTextWidget(rs, text: title)),
      isLimited
          ? DataCell(Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                basic,
                MyWidget().getTextWidget(rs, text: tr('limited'), size: 10, color: MyColors.mustard),
              ],
            )))
          : DataCell(Center(child: basic)),
      DataCell(Center(child: premium)),
    ]);
  }

  sendPremiumEmail() async {
    final response = await http.post(
      Uri.parse('https://us-central1-podo-49335.cloudfunctions.net/onSendPremiumEmail'),
      body: {
        'email': User().email,
        'name': User().name,
      },
    );

    if (response.statusCode == 200) {
      print('프리미엄 이메일 전송 성공');
    } else {
      print('프리미엄 이메일 전송 실패: $response');
    }
  }

  runPurchase() async {
    package ??= sixMonthsOffering!.availablePackages[0];
    StoreProduct storeProduct = package!.storeProduct;
    String store = '';
    if (Platform.isIOS) {
      store = 'iOS';
    } else if (Platform.isAndroid) {
      store = 'Android';
    }
    await analytics.logBeginCheckout(
        currency: storeProduct.currencyCode,
        value: storeProduct.price,
        parameters: {'item': storeProduct.identifier, 'store': store});
    final Trace purchaseTrace = FirebasePerformance.instance.newTrace(PURCHASE_TRACE);
    purchaseTrace.start();
    setState(() {
      isPurchasing = true;
    });
    try {
      CustomerInfo purchaserInfo = await Purchases.purchasePackage(package!);
      purchaseTrace.putAttribute(PURCHASE_STATUS, SUCCESS);
      await analytics.logPurchase(
          currency: storeProduct.currencyCode,
          value: storeProduct.price,
          parameters: {'item': storeProduct.identifier, 'store': store});
      if (purchaserInfo.entitlements.active.isNotEmpty) {
        Purchases.setEmail(User().email);
        Purchases.setDisplayName(User().name);
        Purchases.setPushToken(User().fcmToken ?? '');
        String? appInstanceId = await analytics.appInstanceId;
        Purchases.setFirebaseAppInstanceId(appInstanceId!);
        await Database().updateDoc(collection: 'Users', docId: User().id, key: 'status', value: 2);
        MyWidget().showSnackbarWithPodo(rs, title: tr('purchaseTitle'), content: tr('purchaseContent'));
        User().getUser();
        sendPremiumEmail();
        Get.offNamedUntil(MyStrings.routeMainFrame, ModalRoute.withName(MyStrings.routeLogo));
      }
    } on PlatformException catch (e) {
      setState(() {
        isPurchasing = false;
      });
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      purchaseTrace.putAttribute(PURCHASE_STATUS, FAILED);
      purchaseTrace.putAttribute(ERROR_CODE, errorCode.toString());
      await analytics.logEvent(name: 'purchase_failed', parameters: {'error_code': errorCode.toString()});
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        FirebaseCrashlytics.instance.log('Purchase error: $errorCode');
        MyWidget().showSnackbar(rs, title: tr('error'), message: errorCode.toString());
      }
    }
    purchaseTrace.stop();
  }

  Map<String, String> getDiscountInfo(Offering monthlyOffering, Offering sixMonthsOffering, Offering yearlyOffering) {
    String? monthlyPriceString = monthlyOffering.availablePackages[0].storeProduct.priceString;
    double? sixMonthsPrice = sixMonthsOffering.availablePackages[0].storeProduct.price;
    double? yearlyPrice = yearlyOffering.availablePackages[0].storeProduct.price;

    // 통화 기호 추출
    String currencySymbol = monthlyPriceString.replaceAll(RegExp(r'[0-9.,]'), '').trim();

    // 숫자 문자열 추출
    String numericString = monthlyPriceString.replaceAll(RegExp(r'[^\d.]'), '');

    // 12배 계산
    double price = double.parse(numericString);
    double multipliedPrice12 = price * 12;
    double multipliedPrice6 = price * 6;

    int discountRate12 = ((multipliedPrice12 - yearlyPrice) / multipliedPrice12 * 100).round();
    int discountRate6 = ((multipliedPrice6 - sixMonthsPrice) / multipliedPrice6 * 100).round();

    // 입력값에 소수점이 포함되어 있었는지 확인
    bool hasDecimal = numericString.contains('.');

    // 포맷 선택
    final formatter = NumberFormat(hasDecimal ? "#,##0.00" : "#,###");

    // 결과 포맷 후 출력
    String originalPrice12 = '$currencySymbol${formatter.format(multipliedPrice12)}';
    String originalPrice6 = '$currencySymbol${formatter.format(multipliedPrice6)}';
    String monthlyFromYearlyPrice = '$currencySymbol${formatter.format(yearlyPrice / 12)}';
    String monthlyFromSixMonthsPrice = '$currencySymbol${formatter.format(sixMonthsPrice / 6)}';

    return {
      'originalPrice12': originalPrice12,
      'originalPrice6': originalPrice6,
      'discountRate12': '$discountRate12%',
      'discountRate6': '$discountRate6%',
      'monthlyPrice12': monthlyFromYearlyPrice,
      'monthlyPrice6': monthlyFromSixMonthsPrice,
    };
  }

  @override
  Widget build(BuildContext context) {
    rs = ResponsiveSize(context);
    return Scaffold(
      appBar: MyWidget().getAppbar(context, rs, title: ''),
      body: Column(
        children: [
          msgForTrial != null
              ? Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      color: trialLeftDate! > 3 ? MyColors.purple : MyColors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyWidget().getTextWidget(rs,
                              text: msgForTrial, color: Colors.white, isTextAlignCenter: true, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<String>(
                      stream: getTimeLeftStream(),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(CupertinoIcons.clock_fill, size: 15, color: MyColors.red),
                              const SizedBox(width: 5),
                              MyWidget()
                                  .getTextWidget(rs, text: snapshot.data!, color: MyColors.red, isBold: true),
                              const SizedBox(width: 20),
                            ],
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            isPodoStoryActive = !isPodoStoryActive;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: Icon(Icons.travel_explore, color: MyColors.mustard),
                        label: MyWidget().getTextWidget(rs,
                            text: 'Discover The Podo Story',
                            size: 16,
                            color: MyColors.mustard,
                            isBold: true,
                            hasUnderline: true)),
                  ),
                  const SizedBox(height: 20),
                  Visibility(
                    visible: isPodoStoryActive,
                    child: Column(
                      children: [
                        Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3))
                            ]),
                            child: Image.asset('assets/images/danny.png',
                                width: rs.getSize(100), height: rs.getSize(100))),
                        SizedBox(height: rs.getSize(20)),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            TextSpan(
                                text: '안녕하세요?\n\n',
                                style: TextStyle(
                                    fontFamily: 'KoreanFont',
                                    color: Theme.of(context).primaryColor,
                                    fontSize: ResponsiveSize(context).getSize(20),
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: tr('premium1'),
                                style: TextStyle(
                                    fontFamily: 'EnglishFont',
                                    color: Theme.of(context).primaryColor,
                                    fontSize: ResponsiveSize(context).getSize(15))),
                          ]),
                        ),
                        SizedBox(height: rs.getSize(30)),
                        Container(
                            decoration: const BoxDecoration(
                              color: MyColors.navyLight,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.asset('assets/images/quote_upper.png', color: MyColors.purple),
                                      SizedBox(width: rs.getSize(5)),
                                      Expanded(
                                          child: MyWidget().getTextWidget(rs,
                                              text: tr('premium2'),
                                              color: MyColors.purple,
                                              size: 18,
                                              isBold: true,
                                              isTextAlignCenter: true)),
                                      SizedBox(width: rs.getSize(5)),
                                      Image.asset('assets/images/quote_lower.png', color: MyColors.purple),
                                    ],
                                  ),
                                  const Divider(color: MyColors.purple, thickness: 1.3),
                                  const SizedBox(height: 20),
                                  MyWidget().getTextWidget(
                                      height: 1.5,
                                      rs,
                                      text: tr('aboutDanny1'),
                                      color: MyColors.purple,
                                      isTextAlignCenter: true),
                                  const SizedBox(height: 10),
                                  MyWidget().getTextWidget(
                                      height: 1.5,
                                      rs,
                                      text: tr('aboutDanny2'),
                                      color: MyColors.purple,
                                      isTextAlignCenter: true,
                                      isBold: true,
                                      size: 18),
                                  const SizedBox(height: 10),
                                  MyWidget().getTextWidget(
                                      height: 1.5,
                                      rs,
                                      text: tr('aboutDanny3'),
                                      color: MyColors.purple,
                                      isTextAlignCenter: true),
                                  const SizedBox(height: 10),
                                  MyWidget().getTextWidget(
                                      height: 1.5,
                                      rs,
                                      text: tr('aboutDanny4'),
                                      color: MyColors.purple,
                                      isTextAlignCenter: true,
                                      isBold: true,
                                      size: 18),
                                  const SizedBox(height: 10),
                                  MyWidget().getTextWidget(
                                      height: 1.5,
                                      rs,
                                      text: tr('aboutDanny5'),
                                      color: MyColors.purple,
                                      isTextAlignCenter: true),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            )),
                        Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              color: MyColors.navyLight,
                              height: 100,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                color: MyColors.mustardLight,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Image.asset('assets/images/quote_upper.png', color: MyColors.mustard),
                                        SizedBox(width: rs.getSize(5)),
                                        Expanded(
                                            child: MyWidget().getTextWidget(rs,
                                                text: tr('premium3'),
                                                color: MyColors.mustard,
                                                size: 18,
                                                isBold: true,
                                                isTextAlignCenter: true)),
                                        SizedBox(width: rs.getSize(5)),
                                        Image.asset('assets/images/quote_lower.png', color: MyColors.mustard),
                                      ],
                                    ),
                                    const Divider(color: MyColors.mustard, thickness: 1.3),
                                    const SizedBox(height: 20),
                                    MyWidget().getTextWidget(rs, text: tr('premium4'), color: MyColors.mustard),
                                    const SizedBox(height: 20),
                                    Container(
                                        decoration: const BoxDecoration(
                                            color: MyColors.mustard,
                                            borderRadius: BorderRadius.all(Radius.circular(20))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: MyWidget().getTextWidget(
                                              height: 1.5, rs, text: tr('premium5'), color: MyColors.pink),
                                        )),
                                    const SizedBox(height: 20),
                                    Container(
                                        decoration: const BoxDecoration(
                                            color: MyColors.mustard,
                                            borderRadius: BorderRadius.all(Radius.circular(20))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: MyWidget().getTextWidget(
                                              height: 1.5, rs, text: tr('premium6'), color: MyColors.pink),
                                        )),
                                    const SizedBox(height: 20),
                                    MyWidget().getTextWidget(
                                        height: 1.5,
                                        rs,
                                        text: tr('premium7'),
                                        color: MyColors.mustard,
                                        isTextAlignCenter: true),
                                    const SizedBox(height: 10),
                                    MyWidget().getTextWidget(rs,
                                        text: tr('premium8'), color: MyColors.mustard, isBold: true),
                                    MyWidget().getTextWidget(rs, text: tr('premium9'), color: MyColors.mustard),
                                    MyWidget().getTextWidget(rs, text: tr('premium10'), color: MyColors.mustard),
                                    const SizedBox(height: 10),
                                    MyWidget().getTextWidget(rs, text: tr('premium11'), color: MyColors.mustard),
                                    const SizedBox(height: 10),
                                    MyWidget().getTextWidget(rs,
                                        text: tr('premium12'), color: MyColors.mustard, isBold: true, size: 20),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              color: MyColors.mustardLight,
                              height: 100,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                color: MyColors.pink,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Image.asset('assets/images/quote_upper.png', color: MyColors.pinkDark),
                                        SizedBox(width: rs.getSize(5)),
                                        Expanded(
                                            child: MyWidget().getTextWidget(rs,
                                                text: tr('premium13'),
                                                color: MyColors.pinkDark,
                                                size: 18,
                                                isBold: true,
                                                isTextAlignCenter: true)),
                                        SizedBox(width: rs.getSize(5)),
                                        Image.asset('assets/images/quote_lower.png', color: MyColors.pinkDark),
                                      ],
                                    ),
                                    const Divider(color: MyColors.pinkDark, thickness: 1.3),
                                    const SizedBox(height: 20),
                                    MyWidget().getTextWidget(
                                        height: 1.5,
                                        rs,
                                        text: tr('premium14'),
                                        color: MyColors.pinkDark,
                                        isTextAlignCenter: true),
                                    MyWidget().getTextWidget(rs, text: tr('premium15'), color: MyColors.pinkDark),
                                    const SizedBox(height: 10),
                                    MyWidget().getTextWidget(rs,
                                        text: tr('premium16'), color: MyColors.pinkDark, size: 18, isBold: true),
                                    const SizedBox(height: 10),
                                    MyWidget().getTextWidget(
                                        height: 1.5,
                                        rs,
                                        text: tr('premium17'),
                                        color: MyColors.pinkDark,
                                        isTextAlignCenter: true),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        color: MyColors.pink,
                        height: 100,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: MyColors.navyLightLight,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset('assets/images/quote_upper.png', color: MyColors.purple),
                                  SizedBox(width: rs.getSize(5)),
                                  Expanded(
                                      child: MyWidget().getTextWidget(rs,
                                          text: tr('premium18'),
                                          color: MyColors.purple,
                                          size: 18,
                                          isBold: true,
                                          isTextAlignCenter: true)),
                                  SizedBox(width: rs.getSize(5)),
                                  Image.asset('assets/images/quote_lower.png', color: MyColors.purple),
                                ],
                              ),
                              const Divider(color: MyColors.purple, thickness: 1.3),
                              const SizedBox(height: 20),
                              MyWidget().getTextWidget(
                                  height: 1.5,
                                  rs,
                                  text: tr('premium19'),
                                  color: MyColors.purple,
                                  isTextAlignCenter: true),
                              const SizedBox(height: 10),
                              MyWidget().getTextWidget(
                                  height: 1.5,
                                  rs,
                                  text: tr('premium20'),
                                  color: MyColors.purple,
                                  isTextAlignCenter: true,
                                  isBold: true),
                              const SizedBox(height: 20),
                              DataTable(
                                horizontalMargin: 0,
                                columns: <DataColumn>[
                                  getDataColumn(''),
                                  getDataColumn('Basic'),
                                  getDataColumn('Premium'),
                                ],
                                rows: <DataRow>[
                                  getDataRow(
                                      tr('lesson'),
                                      const Icon(Icons.check_circle_outline, color: MyColors.mustard),
                                      const Icon(Icons.check_circle_outline, color: MyColors.green),
                                      isLimited: true),
                                  getDataRow(
                                      tr('reading'),
                                      const Icon(Icons.check_circle_outline, color: MyColors.mustard),
                                      const Icon(Icons.check_circle_outline, color: MyColors.green),
                                      isLimited: true),
                                  getDataRow(
                                      tr('flashcard'),
                                      const Icon(Icons.check_circle_outline, color: MyColors.mustard),
                                      const Icon(Icons.check_circle_outline, color: MyColors.green),
                                      isLimited: true),
                                  getDataRow(
                                      tr('writingCorrection'),
                                      const Icon(Icons.remove_circle_outline, color: MyColors.red),
                                      const Icon(Icons.check_circle_outline, color: MyColors.green)),
                                  // getDataRow(
                                  //     tr('podosMsg'),
                                  //     const Icon(Icons.remove_circle_outline, color: MyColors.red),
                                  //     const Icon(Icons.check_circle_outline, color: MyColors.green)),
                                  getDataRow(
                                      tr('adFree'),
                                      const Icon(Icons.remove_circle_outline, color: MyColors.red),
                                      const Icon(Icons.check_circle_outline, color: MyColors.green)),
                                  getDataRow(
                                      tr('workbookDownload'),
                                      const Icon(Icons.remove_circle_outline, color: MyColors.red),
                                      const Icon(Icons.check_circle_outline, color: MyColors.green))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<Offerings>(
                    future: offerings,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                        final monthlyOffering = snapshot.data?.getOffering("1 Month");
                        sixMonthsOffering = snapshot.data?.getOffering("6 Months");
                        final yearlyOffering = snapshot.data?.getOffering("1 Year");
                        Map<String, String> discountInfo =
                        getDiscountInfo(monthlyOffering!, sixMonthsOffering!, yearlyOffering!);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(10),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                        color: selectedPlan == 0 ? MyColors.purple : Colors.transparent, width: 2),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    package = monthlyOffering.availablePackages[0];
                                    selectedPlan = 0;
                                    plan = 'Monthly';
                                  });
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyWidget().getTextWidget(rs,
                                        text: 'Monthly', isBold: true, size: 18, color: MyColors.purple),
                                    const SizedBox(height: 10),
                                    MyWidget().getTextWidget(rs,
                                        text: monthlyOffering.serverDescription, color: MyColors.navy),
                                    Divider(),
                                    MyWidget().getTextWidget(rs,
                                        text: monthlyOffering.availablePackages[0].storeProduct.priceString,
                                        size: 18,
                                        isBold: true)
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(10),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                        color: selectedPlan == 1 ? MyColors.purple : Colors.transparent, width: 2),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    package = sixMonthsOffering!.availablePackages[0];
                                    selectedPlan = 1;
                                    plan = 'Six Months';
                                  });
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        MyWidget().getTextWidget(rs,
                                            text: 'Six Months', isBold: true, size: 18, color: MyColors.purple),
                                        MyWidget().getRoundedContainer(
                                            widget: Text(
                                              '${discountInfo['discountRate6']!} off',
                                              style: TextStyle(
                                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            bgColor: MyColors.red,
                                            radius: 15,
                                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    MyWidget().getTextWidget(rs,
                                        text: sixMonthsOffering!.serverDescription, color: MyColors.navy),
                                    Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              MyWidget().getTextWidget(rs,
                                                  text: discountInfo['originalPrice6'],
                                                  hasCancelLine: true,
                                                  color: MyColors.navy),
                                              const SizedBox(width: 10),
                                              MyWidget().getTextWidget(rs,
                                                  text:
                                                  sixMonthsOffering!.availablePackages[0].storeProduct.priceString,
                                                  size: 18,
                                                  isBold: true),
                                            ],
                                          ),
                                        ),
                                        MyWidget().getTextWidget(rs,
                                            text: '${discountInfo['monthlyPrice6']} / month')
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(10),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                        color: selectedPlan == 2 ? MyColors.purple : Colors.transparent, width: 2),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    package = yearlyOffering.availablePackages[0];
                                    selectedPlan = 2;
                                    plan = 'Yearly';
                                  });
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        MyWidget().getTextWidget(rs,
                                            text: 'Yearly', isBold: true, size: 18, color: MyColors.purple),
                                        MyWidget().getRoundedContainer(
                                            widget: Text(
                                              '${discountInfo['discountRate12']!} off',
                                              style: TextStyle(
                                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            bgColor: MyColors.red,
                                            radius: 15,
                                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    MyWidget().getTextWidget(rs,
                                        text: yearlyOffering.serverDescription, color: MyColors.navy),
                                    Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              MyWidget().getTextWidget(rs,
                                                  text: discountInfo['originalPrice12'],
                                                  hasCancelLine: true,
                                                  color: MyColors.navy),
                                              const SizedBox(width: 10),
                                              MyWidget().getTextWidget(rs,
                                                  text:
                                                  yearlyOffering.availablePackages[0].storeProduct.priceString,
                                                  size: 18,
                                                  isBold: true),
                                            ],
                                          ),
                                        ),
                                        MyWidget().getTextWidget(rs,
                                            text: '${discountInfo['monthlyPrice12']} / month')
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyWidget().getRoundBtnWidget(rs, text: 'Get $plan Premium', verticalPadding: 10, f: () {
                            runPurchase();
                          }),
                        ],
                      ),
                      Visibility(
                        visible: isPurchasing,
                        child: Positioned(
                          top: rs.getSize(0),
                          right: rs.getSize(20),
                          child: SizedBox(
                              width: rs.getSize(18),
                              height: rs.getSize(18),
                              child: const CircularProgressIndicator(strokeWidth: 3)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: tr('termOfUse'),
                          style: TextStyle(color: Colors.blue, fontSize: ResponsiveSize(context).getSize(15)),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(Uri.parse('https://www.podokorean.com/termsOfUse.html'));
                            },
                        ),
                        TextSpan(
                            text: tr('and'),
                            style: TextStyle(color: MyColors.grey, fontSize: ResponsiveSize(context).getSize(15))),
                        TextSpan(
                          text: tr('privacyPolicy'),
                          style: TextStyle(color: Colors.blue, fontSize: ResponsiveSize(context).getSize(15)),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(Uri.parse('https://www.podokorean.com/privacyPolicy.html'));
                            },
                        )
                      ]),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
