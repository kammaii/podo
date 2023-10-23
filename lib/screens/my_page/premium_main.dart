import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class PremiumMain extends StatefulWidget {
  PremiumMain({Key? key}) : super(key: key);

  @override
  State<PremiumMain> createState() => _PremiumMainState();
}

class _PremiumMainState extends State<PremiumMain> {
  late List<bool> selector;
  late int selectedPlan;
  bool isPurchasing = false;
  late ResponsiveSize rs;
  final PURCHASE_TRACE = 'purchase_trace';
  final PURCHASE_STATUS = 'purchase_status';
  final SUCCESS = 'success';
  final FAILED = 'failed';
  final ERROR_CODE = 'errorCode';

  DataColumn getDataColumn(String label) {
    return DataColumn(
      label: Expanded(
        child: Center(child: MyWidget().getTextWidget(rs, text: label)),
      ),
    );
  }

  DataRow getDataRow(String title, Widget basic, Widget premium) {
    return DataRow(cells: <DataCell>[
      DataCell(MyWidget().getTextWidget(rs, text: title)),
      DataCell(Center(child: basic)),
      DataCell(Center(child: premium)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    rs = ResponsiveSize(context);
    return Scaffold(
      appBar: MyWidget().getAppbar(rs, title: ''),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: rs.getSize(15), right: rs.getSize(15), bottom: rs.getSize(50), top: rs.getSize(20)),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset('assets/images/quote_upper.png', color: MyColors.purple),
                              SizedBox(width: rs.getSize(5)),
                              Expanded(
                                  child: MyWidget().getTextWidget(rs,
                                      text: tr('premiumComment'),
                                      color: MyColors.purple,
                                      isTextAlignCenter: true,
                                      size: 20)),
                              SizedBox(width: rs.getSize(5)),
                              Image.asset('assets/images/quote_lower.png', color: MyColors.purple),
                            ],
                          ),
                          SizedBox(height: rs.getSize(20)),
                          DataTable(
                            horizontalMargin: 0,
                            columns: <DataColumn>[
                              getDataColumn(''),
                              getDataColumn('Basic'),
                              getDataColumn('Premium'),
                            ],
                            rows: <DataRow>[
                              getDataRow(tr('lesson'), const Icon(Icons.check_circle_outline, color: MyColors.green),
                                  const Icon(Icons.check_circle_outline, color: MyColors.green)),
                              getDataRow(
                                  tr('lessonDetail'),
                                  const Icon(Icons.remove_circle_outline, color: MyColors.red),
                                  const Icon(Icons.check_circle_outline, color: MyColors.green)),
                              getDataRow(
                                  tr('writingCorrection'),
                                  const Icon(Icons.remove_circle_outline, color: MyColors.red),
                                  const Icon(Icons.check_circle_outline, color: MyColors.green)),
                              getDataRow(tr('reading'), MyWidget().getTextWidget(rs, text: tr('limited')),
                                  const Icon(Icons.check_circle_outline, color: MyColors.green)),
                              getDataRow(tr('flashcard'), MyWidget().getTextWidget(rs, text: tr('limit20')),
                                  const Icon(Icons.check_circle_outline, color: MyColors.green)),
                              getDataRow(tr('podosMsg'), const Icon(Icons.remove_circle_outline, color: MyColors.red),
                                  const Icon(Icons.check_circle_outline, color: MyColors.green)),
                              getDataRow(tr('adFree'), const Icon(Icons.remove_circle_outline, color: MyColors.red),
                                  const Icon(Icons.check_circle_outline, color: MyColors.green))
                            ],
                          ),
                          Divider(height: rs.getSize(30), thickness: rs.getSize(2), color: MyColors.purple),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: tr('premiumDetail'),
                                  style:
                                      TextStyle(color: MyColors.grey, fontSize: ResponsiveSize(context).getSize(15))),
                              TextSpan(
                                text: tr('termOfUse'),
                                style: TextStyle(color: Colors.blue, fontSize: ResponsiveSize(context).getSize(15)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(
                                        Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'));
                                  },
                              ),
                              TextSpan(
                                  text: tr('and'),
                                  style:
                                      TextStyle(color: MyColors.grey, fontSize: ResponsiveSize(context).getSize(15))),
                              TextSpan(
                                text: tr('privacyPolicy'),
                                style: TextStyle(color: Colors.blue, fontSize: ResponsiveSize(context).getSize(15)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(Uri.parse('https://podo-49335.web.app/privacyPolicy.html'));
                                  },
                              )
                            ]),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                FutureBuilder<Offerings>(
                  future: Purchases.getOfferings(),
                  builder: (context, snapshot) {
                    Package? package;
                    if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                      final offering = snapshot.data?.current;
                      package = offering?.availablePackages[0];
                      print(package);

                      return Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: rs.getSize(15), vertical: rs.getSize(20)),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(0),
                                elevation: 5,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                backgroundColor: Colors.transparent,
                              ),
                              onPressed: () async {
                                final Trace purchaseTrace = FirebasePerformance.instance.newTrace(PURCHASE_TRACE);
                                purchaseTrace.start();

                                setState(() {
                                  isPurchasing = true;
                                });
                                try {
                                  CustomerInfo purchaserInfo = await Purchases.purchasePackage(package!);
                                  purchaseTrace.putAttribute(PURCHASE_STATUS, SUCCESS);
                                  if (purchaserInfo.entitlements.active.isNotEmpty) {
                                    Purchases.setEmail(User().email);
                                    Purchases.setDisplayName(User().name);
                                    Purchases.setPushToken(User().fcmToken ?? '');
                                    String? appInstanceId = await FirebaseAnalytics.instance.appInstanceId;
                                    Purchases.setFirebaseAppInstanceId(appInstanceId!);
                                    Database()
                                        .updateDoc(collection: 'Users', docId: User().id, key: 'status', value: 2);
                                    MyWidget().showSnackbarWithPodo(rs,
                                        title: tr('purchaseTitle'), content: tr('purchaseContent'));
                                    User().getUser();
                                    Get.offNamedUntil(
                                        MyStrings.routeMainFrame, ModalRoute.withName(MyStrings.routeLogo));
                                  }
                                } on PlatformException catch (e) {
                                  setState(() {
                                    isPurchasing = false;
                                  });
                                  var errorCode = PurchasesErrorHelper.getErrorCode(e);
                                  purchaseTrace.putAttribute(PURCHASE_STATUS, FAILED);
                                  purchaseTrace.putAttribute(ERROR_CODE, errorCode.toString());
                                  if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
                                    FirebaseCrashlytics.instance.log('Purchase error: $errorCode');
                                    MyWidget().showSnackbar(rs, title: tr('error'), message: errorCode.toString());
                                  }
                                }
                                await FirebaseAnalytics.instance.logPurchase();
                                purchaseTrace.stop();
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: rs.getSize(23), vertical: rs.getSize(10)),
                                    decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [MyColors.purple, MyColors.green]),
                                        borderRadius: BorderRadius.circular(30)),
                                    child: offering != null
                                        ? Row(
                                            children: [
                                              Icon(FontAwesomeIcons.crown, color: Colors.white, size: rs.getSize(30)),
                                              SizedBox(width: rs.getSize(18)),
                                              Expanded(
                                                child: Center(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      MyWidget().getTextWidget(rs,
                                                          text: 'Get Podo Premium!',
                                                          color: Colors.white,
                                                          size: rs.getSize(18),
                                                          isBold: true),
                                                      MyWidget().getTextWidget(rs,
                                                          text: offering.identifier,
                                                          color: Colors.white,
                                                          size: rs.getSize(18),
                                                          isBold: true),
                                                      MyWidget().getTextWidget(rs,
                                                          text: offering.serverDescription,
                                                          color: Colors.white,
                                                          size: rs.getSize(15),
                                                          isBold: true)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: rs.getSize(18)),
                                              MyWidget().getTextWidget(rs,
                                                  text: offering.availablePackages[0].storeProduct.priceString,
                                                  color: Colors.white,
                                                  size: 18,
                                                  isBold: true),
                                            ],
                                          )
                                        : Center(
                                            child: MyWidget()
                                                .getTextWidget(rs, text: tr('failedOffering'), color: Colors.white)),
                                  )),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isPurchasing,
                            child: Positioned(
                              top: rs.getSize(20),
                              right: rs.getSize(20),
                              child: SizedBox(
                                  width: rs.getSize(18),
                                  height: rs.getSize(18),
                                  child: const CircularProgressIndicator(strokeWidth: 3)),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ],
            ),
            Offstage(
              offstage: !isPurchasing,
              child: const Opacity(opacity: 0.2, child: ModalBarrier(dismissible: false, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
