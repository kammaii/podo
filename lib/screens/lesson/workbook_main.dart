import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/lesson/lesson_course.dart';
import 'package:podo/screens/lesson/workbook.dart';
import 'package:podo/screens/lesson/workbook_controller.dart';
import 'package:podo/screens/my_page/user.dart';
import 'package:podo/values/my_colors.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_size_text/auto_size_text.dart';

class LessonItem {
  late String title;
  late String subTitle;
  late List<dynamic> audios;
  bool isExpanded = false;

  LessonItem(dynamic lesson) {
    title = lesson['title'] ?? '';
    subTitle = lesson['subTitle'] ?? '';
    audios = lesson['audios'] ?? '';
  }
}

class WorkbookMain extends StatefulWidget {
  const WorkbookMain({Key? key}) : super(key: key);

  @override
  State<WorkbookMain> createState() => _WorkbookMainState();
}

class _WorkbookMainState extends State<WorkbookMain> {
  late ResponsiveSize rs;
  final courseId = Get.arguments;
  String fo = User().language;
  late List<LessonItem> items;
  bool isLoaded = false;
  late Workbook workbook;
  String? workbookPrice;
  late bool hasDownloaded;
  ReceivePort _port = ReceivePort();
  late Map<int, List<Widget>> stateMap;
  final controller = Get.put(WorkbookController());
  final Map<String, Uint8List> _imageCache = {};

  @override
  void initState() {
    super.initState();
    Database()
        .getDocs(
            query: FirebaseFirestore.instance.collection('LessonCourses/$courseId/Workbooks').orderBy('orderId'))
        .then((snapshots) async {
      workbook = Workbook.fromJson(snapshots[0].data() as Map<String, dynamic>);
      items = [];
      for (dynamic lesson in workbook.lessons) {
        items.add(LessonItem(lesson));
      }
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      hasDownloaded = customerInfo.entitlements.active[workbook.productId] != null ? true : false;
      print('HAS DOWNLOADED: $hasDownloaded');

      await Purchases.getOfferings().then((value) {
        workbookPrice = value.getOffering(workbook.productId)?.lifetime?.storeProduct.priceString;
      });
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          isLoaded = true;
        });
        setStateMap();
      });
      if (!FlutterDownloader.initialized) {
        await FlutterDownloader.initialize();
      }

      IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
      _port.listen((dynamic data) {
        print('PORT LISTEN!');
        int status = data[1];
        if (status == 3) {
          print("Download completed");
          controller.setDownloadState(2);
        } else if (status == 4) {
          print("Download failed");
          controller.setDownloadState(3);
        }
      });

      FlutterDownloader.registerCallback(downloadCallback).then((value) => print('콜백등록'));
    });
  }

  @override
  void dispose() {
    PlayAudio().reset();
    controller.downloadState.value = 0;
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  void setStateMap() {
    stateMap = {
      // 다운중
      1: [
        SizedBox(
          height: rs.getSize(15),
          width: rs.getSize(15),
          child: CircularProgressIndicator(
            strokeWidth: rs.getSize(1.2),
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        MyWidget().getTextWidget(rs, text: tr('downloadStart'), color: Theme.of(context).primaryColor),
      ],
      // 완료
      2: [
        Icon(Icons.check_circle, color: Theme.of(context).highlightColor, size: rs.getSize(18)),
        const SizedBox(width: 8),
        MyWidget().getTextWidget(rs, text: tr('downloadComplete'), color: Theme.of(context).highlightColor),
      ],
      // 실패
      3: [
        Icon(Icons.sms_failed_outlined, color: Theme.of(context).focusColor, size: rs.getSize(18)),
        const SizedBox(width: 8),
        MyWidget().getTextWidget(rs, text: tr('error'), color: Theme.of(context).focusColor),
      ],
    };
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  closePanels() {
    for (LessonItem item in items) {
      item.isExpanded = false;
    }
  }

  List<ExpansionPanel> getExpansionPanel() {
    List<ExpansionPanel> panels = [];
    for (int i = 0; i < items.length; i++) {
      LessonItem item = items[i];
      panels.add(ExpansionPanel(
          canTapOnHeader: true,
          isExpanded: item.isExpanded,
          headerBuilder: (context, isExpanded) {
            return Padding(
              padding: EdgeInsets.all(rs.getSize(8)),
              child: ListTile(
                leading: MyWidget()
                    .getTextWidget(rs, text: 'Lesson ${i + 1}', color: Theme.of(context).secondaryHeaderColor),
                title: AutoSizeText(
                  item.title,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                  maxLines: 1,
                ),
                subtitle: item.subTitle.isNotEmpty
                    ? AutoSizeText(
                        '(${item.subTitle})',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                        maxLines: 1,
                      )
                    : const SizedBox.shrink(),
              ),
            );
          },
          body: Column(
            children: [
              GridView.builder(
                padding: EdgeInsets.all(rs.getSize(20)),
                shrinkWrap: true,
                itemCount: item.audios.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemBuilder: (context, index) {
                  List<String> audio = item.audios[index].split('&');
                  return MyWidget().getRoundBtnWidget(rs,
                      text: audio[0],
                      textSize: 15,
                      fontColor: MyColors.purple,
                      bgColor: MyColors.navyLight,
                      verticalPadding: 1,
                      horizontalPadding: 3, f: () {
                    PlayAudio().playWorkbook(workbook.id, audio[1]);
                  });
                },
              ),
            ],
          )));
    }
    return panels;
  }

  void downloadWorkbook() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    controller.setDownloadState(1);
    final extDir = await getExternalStorageDirectory();
    final filePath = "${extDir!.path}/${workbook.pdfFile}";
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
    final ref = FirebaseStorage.instance.ref().child('Workbooks/${workbook.id}/${workbook.pdfFile}');
    final url = await ref.getDownloadURL();

    await FlutterDownloader.enqueue(
      url: url,
      savedDir: extDir.path,
      fileName: workbook.pdfFile,
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  Widget _getCachedImage(String base64Str) {
    if (_imageCache.containsKey(base64Str)) {
      return Image.memory(_imageCache[base64Str]!, height: rs.getSize(150), width: rs.getSize(100));
    } else {
      var bytes = base64.decode(base64Str);
      _imageCache[base64Str] = bytes;
      return Image.memory(bytes, height: rs.getSize(150), width: rs.getSize(100));
    }
  }

  @override
  Widget build(BuildContext context) {
    rs = ResponsiveSize(context);
    return Scaffold(
        appBar: MyWidget().getAppbar(context, rs, title: isLoaded ? workbook.title : ''),
        body: isLoaded
            ? Padding(
                padding: EdgeInsets.all(rs.getSize(20)),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Visibility(
                          visible: workbook.hasFreeOption,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(FontAwesomeIcons.crown,
                                      color: Theme.of(context).primaryColor, size: rs.getSize(18)),
                                  const SizedBox(width: 10),
                                  FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: MyWidget().getTextWidget(rs,
                                          text: tr('freeDownload'),
                                          color: Theme.of(context).primaryColor,
                                          isBold: true)),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          )),
                      Row(
                        children: [
                          workbook.image.isNotEmpty
                              ? Column(
                                  children: [
                                    Image.memory(base64Decode(workbook.image),
                                        width: rs.getSize(100), fit: BoxFit.fitWidth),
                                    TextButton(
                                        onPressed: () {
                                          Get.dialog(Stack(
                                            children: [
                                              Swiper(
                                                itemBuilder: (context, index) {
                                                  return _getCachedImage(workbook.sampleImages[index]);
                                                },
                                                loop: true,
                                                itemCount: workbook.sampleImages.length,
                                                viewportFraction: 0.8,
                                                scale: 0.8,
                                                pagination: const SwiperPagination(),
                                              ),
                                              Positioned(
                                                top: 20,
                                                right: 20,
                                                child: Theme(
                                                  data: Theme.of(context)
                                                      .copyWith(highlightColor: MyColors.navyLight),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: IconButton(
                                                        icon: const Icon(Icons.cancel, color: Colors.white),
                                                        onPressed: () {
                                                          Get.back();
                                                        }),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ));
                                        },
                                        child: MyWidget().getTextWidget(rs,
                                            text: tr('preview'),
                                            color: Theme.of(context).primaryColor,
                                            isBold: true)),
                                  ],
                                )
                              : const SizedBox.shrink(),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyWidget().getRoundBtnWidget(rs, text: tr('buyBook'), f: () {
                                  launchUrl(Uri.parse(workbook.storeLink));
                                },
                                    textSize: 15,
                                    verticalPadding: 3,
                                    horizontalPadding: 5,
                                    borderRadius: 20,
                                    bgColor: Theme.of(context).canvasColor),
                                MyWidget().getRoundBtnWidget(rs,
                                    text: hasDownloaded
                                        ? tr('pdfDownload')
                                        : '${tr('pdfDownload')}  $workbookPrice', f: () async {
                                  if (hasDownloaded || User().status == 2) {
                                    MyWidget().showDialog(context, rs, content: tr('wantDownloadWorkbook'),
                                        yesFn: () {
                                      downloadWorkbook();
                                    });
                                  } else {
                                    Offerings offerings = await Purchases.getOfferings();
                                    String productId = workbook.productId;
                                    Package? package = offerings.getOffering(productId)?.lifetime;
                                    if (package != null) {
                                      CustomerInfo purchaserInfo = await Purchases.purchasePackage(package);
                                      if (purchaserInfo.entitlements.active[productId] != null) {
                                        downloadWorkbook();
                                      }
                                    }
                                  }
                                },
                                    textSize: 15,
                                    verticalPadding: 3,
                                    horizontalPadding: 5,
                                    borderRadius: 20,
                                    bgColor: Theme.of(context).canvasColor),
                                Obx(() => controller.downloadState.value != 0
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: stateMap[controller.downloadState.value]!,
                                      )
                                    : const SizedBox.shrink()),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      MyWidget().getRoundedContainer(
                          radius: 5,
                          widget: Row(
                            children: [
                              Icon(Icons.volume_up_rounded,
                                  color: Theme.of(context).primaryColor, size: rs.getSize(20)),
                              const SizedBox(width: 10),
                              MyWidget()
                                  .getTextWidget(rs, text: tr('audios'), color: Theme.of(context).primaryColor),
                            ],
                          ),
                          bgColor: Theme.of(context).cardColor),
                      const SizedBox(height: 10),
                      Theme(
                        data: Theme.of(context).copyWith(highlightColor: MyColors.navyLight),
                        child: ExpansionPanelList(
                          expansionCallback: (index, isExpanded) {
                            setState(() {
                              closePanels();
                              if (Platform.isIOS) {
                                items[index].isExpanded = !isExpanded;
                              } else {
                                items[index].isExpanded = isExpanded;
                              }
                            });
                          },
                          children: getExpansionPanel(),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()));
  }
}
