import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PremiumMain extends StatefulWidget {
  PremiumMain({Key? key}) : super(key: key);

  @override
  State<PremiumMain> createState() => _PremiumMainState();
}

class _PremiumMainState extends State<PremiumMain> {
  late List<bool> selector;
  late int selectedPlan;
  bool isPurchasing = false;

  DataColumn getDataColumn(String label) {
    return DataColumn(
      label: Expanded(
        child: Center(child: MyWidget().getTextWidget(text: label)),
      ),
    );
  }

  DataRow getDataRow(String title, Widget basic, Widget premium) {
    return DataRow(cells: <DataCell>[
      DataCell(MyWidget().getTextWidget(text: title)),
      DataCell(Center(child: basic)),
      DataCell(Center(child: premium)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyWidget().getAppbar(title: ''),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 50, top: 20),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset('assets/images/quote_upper.png', color: MyColors.purple),
                              const SizedBox(width: 5),
                              Expanded(
                                  child: MyWidget().getTextWidget(
                                      text: tr('premiumComment'),
                                      color: MyColors.purple,
                                      isTextAlignCenter: true,
                                      size: 20)),
                              const SizedBox(width: 5),
                              Image.asset('assets/images/quote_lower.png', color: MyColors.purple),
                            ],
                          ),
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
                                  const Icon(Icons.check_circle_outline, color: MyColors.green),
                                  const Icon(Icons.check_circle_outline, color: MyColors.green)),
                              getDataRow(
                                  tr('lessonDetail'),
                                  const Icon(Icons.remove_circle_outline, color: MyColors.red),
                                  const Icon(Icons.check_circle_outline, color: MyColors.green)),
                              getDataRow(
                                  tr('writingCorrection'),
                                  const Icon(Icons.remove_circle_outline, color: MyColors.red),
                                  const Icon(Icons.check_circle_outline, color: MyColors.green)),
                              getDataRow(tr('reading'), MyWidget().getTextWidget(text: tr('limited')),
                                  MyWidget().getTextWidget(text: tr('all'))),
                              getDataRow(tr('flashcard'), MyWidget().getTextWidget(text: tr('limit20')),
                                  MyWidget().getTextWidget(text: tr('unlimited'))),
                              getDataRow(
                                  tr('podosMsg'),
                                  const Icon(Icons.remove_circle_outline, color: MyColors.red),
                                  const Icon(Icons.check_circle_outline, color: MyColors.green)),
                              getDataRow(
                                  tr('adFree'),
                                  const Icon(Icons.remove_circle_outline, color: MyColors.red),
                                  const Icon(Icons.check_circle_outline, color: MyColors.green))
                            ],
                          ),
                          const Divider(height: 30, thickness: 2, color: MyColors.purple),
                          MyWidget().getTextWidget(
                            text: tr('premiumDetail'),
                            size: 15,
                            color: MyColors.grey,
                          ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(0),
                                elevation: 5,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                backgroundColor: Colors.transparent,
                              ),
                              onPressed: () async {
                                setState(() {
                                  isPurchasing = true;
                                });
                                try {
                                  CustomerInfo purchaserInfo = await Purchases.purchasePackage(package!);
                                  if (purchaserInfo.entitlements.active.isNotEmpty) {
                                    await Purchases.setEmail(User().email);
                                    await Purchases.setDisplayName(User().name);
                                    await Purchases.setPushToken(User().fcmToken ?? '');
                                    // todo:
                                    // String? appInstanceId = await FirebaseAnalytics.instance.appInstanceId;
                                    // await Purchases.setFirebaseAppInstanceId(appInstanceId!);
                                    await Database()
                                        .updateDoc(collection: 'Users', docId: User().id, key: 'status', value: 2);
                                    MyWidget().showSnackbarWithPodo(
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
                                  if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
                                    MyWidget().showSnackbar(title: tr('error'), message: errorCode.toString());
                                  }
                                }
                                //todo: await FirebaseAnalytics.instance.logPurchase();
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 10),
                                    decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [MyColors.purple, MyColors.green]),
                                        borderRadius: BorderRadius.circular(30)),
                                    child: offering != null
                                        ? Row(
                                            children: [
                                              const Icon(FontAwesomeIcons.crown, color: Colors.white, size: 30),
                                              const SizedBox(width: 18),
                                              Expanded(
                                                child: Center(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      MyWidget().getTextWidget(
                                                          text: offering.identifier,
                                                          color: Colors.white,
                                                          size: 18,
                                                          isBold: true),
                                                      MyWidget().getTextWidget(
                                                          text: offering.serverDescription, color: Colors.white)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 18),
                                              MyWidget().getTextWidget(
                                                  text: offering.availablePackages[0].storeProduct.priceString,
                                                  color: Colors.white,
                                                  size: 18,
                                                  isBold: true),
                                            ],
                                          )
                                        : Center(
                                            child: MyWidget().getTextWidget(
                                                text: tr('failedOffering'), color: Colors.white)),
                                  )),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isPurchasing,
                            child: const Positioned(
                              top: 20,
                              right: 20,
                              child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2.5)),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                User().trialStart == null
                    ? TextButton(
                        onPressed: () async {
                          FirebaseMessaging messaging = FirebaseMessaging.instance;
                          NotificationSettings settings = await messaging.requestPermission();
                          if (settings.authorizationStatus == AuthorizationStatus.authorized) {
                            //todo: await FirebaseAnalytics.instance.logEvent(name: 'fcm_approved_after_deny');
                            await User().setTrialAuthorized();
                            Get.offNamedUntil(MyStrings.routeMainFrame, ModalRoute.withName(MyStrings.routeLogo));
                          } else {
                            await User().setTrialDenied();
                          }
                        },
                        child: Text(tr('getFreePremium')))
                    : const SizedBox.shrink(),
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
