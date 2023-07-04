import 'package:animated_icon/animated_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/profile/history.dart';
import 'package:podo/screens/profile/user.dart';
import 'package:podo/screens/reading/reading.dart';
import 'package:podo/screens/reading/reading_controller.dart';
import 'package:podo/screens/reading/reading_title.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class ReadingFrame extends StatefulWidget {
  const ReadingFrame({Key? key}) : super(key: key);

  @override
  _ReadingFrameState createState() => _ReadingFrameState();
}

class _ReadingFrameState extends State<ReadingFrame> with TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  double sliverAppBarHeight = 200.0;
  double sliverAppBarStretchOffset = 100.0;
  ReadingTitle readingTitle = Get.arguments;
  String fo = User().language;
  String sampleImage = 'assets/images/course_hangul.png';
  final KO = 'ko';
  final cardBorderRadius = 8.0;
  bool isImageVisible = true;
  late AnimationController animationController;
  late Animation<double> animation;
  double currentScrollPercent = 0;
  double scrollPosition = 0;
  late List<Reading> readings;
  late Future future;
  final controller = Get.put(ReadingController());

  @override
  void dispose() {
    super.dispose();
    if (currentScrollPercent > 0.1 && currentScrollPercent < 0.9) {
      LocalStorage().prefs.setDouble(readingTitle.id, scrollPosition);
    } else {
      LocalStorage().prefs.remove(readingTitle.id);
    }
    scrollController.dispose();
    PlayAudio().reset();
  }

  @override
  void initState() {
    super.initState();
    final Query query = FirebaseFirestore.instance.collection('ReadingTitles/${readingTitle.id}/Readings').orderBy('orderId');
    future = Database().getDocs(query: query);
    readings = [];
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    animation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    ));
    scrollController.addListener(() => setState(() {
          if (scrollController.offset <= 50) {
            if (animationController.value == 1) {
              animationController.reverse();
            }
          } else {
            if (animationController.value == 0) {
              animationController.forward();
            }
          }
          double maxScroll = scrollController.position.maxScrollExtent;
          scrollPosition = scrollController.position.pixels;
          currentScrollPercent = scrollPosition / maxScroll;
          if (currentScrollPercent <= 0) {
            currentScrollPercent = 0;
          }
          if (currentScrollPercent >= 1) {
            currentScrollPercent = 1;
          }
        }));

    double? position = LocalStorage().prefs.getDouble(readingTitle.id);
    if (position != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.dialog(AlertDialog(
          title: const Text(MyStrings.continueReading),
          actions: [
            TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text(MyStrings.no, style: TextStyle(color: MyColors.navy))),
            TextButton(
                onPressed: () {
                  Get.back();
                  scrollController.animateTo(position,
                      duration: const Duration(milliseconds: 500), curve: Curves.ease);
                },
                child: const Text(MyStrings.yes, style: TextStyle(color: MyColors.purple))),
          ],
        ));
      });
    }
  }

  Widget letterContainer(String text) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white,
            width: 2,
          )),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  sliverAppBar() {
    int wordsLength = 0;
    for(Reading reading in readings){
      int length = reading.words[KO].length;
      wordsLength = wordsLength + length;
    }

    return SliverAppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        color: Colors.white,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      expandedHeight: sliverAppBarHeight,
      collapsedHeight: 60,
      pinned: true,
      stretch: true,
      title: MyWidget().getTextWidget(
        text: '${readingTitle.title[KO]}',
        size: 18,
        color: Colors.white,
        isBold: true,
      ),
      flexibleSpace: Stack(
        children: [
          Container(
            color: MyColors.navyLight,
          ),
          Positioned(
            top: -50,
            right: -30,
            child: Hero(
              tag: 'readingImage:${readingTitle.id}',
              child: FadeTransition(
                opacity: animation,
                child: Image.asset(
                  sampleImage,
                  width: 250,
                ),
              ),
            ),
          ),
          Opacity(
            opacity: 0.2,
            child: Container(
              color: Colors.black,
            ),
          ),
          LinearProgressIndicator(
            value: currentScrollPercent,
            color: MyColors.purple,
            backgroundColor: MyColors.purpleLight,
          ),
          FadeTransition(
            opacity: animation,
            child: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  letterContainer('S'),
                  const SizedBox(width: 10),
                  Text('${readings.length}'),
                  const SizedBox(width: 20),
                  const Text('|'),
                  const SizedBox(width: 20),
                  letterContainer('V'),
                  const SizedBox(width: 10),
                  Text('$wordsLength'),
                ],
              ),
              expandedTitleScale: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  sliverList() {
    int length = readings.length;
    return SliverPadding(
      padding: const EdgeInsets.all(10),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Column(
              children: [
                partContentKo(index),
                const SizedBox(height: 30),
                partWords(index),
                const SizedBox(height: 30),
                partContentFo(index),
                Obx(() {
                  return controller.getIsExpanded(index) ? const SizedBox.shrink() : const Divider();
                }),
                const SizedBox(height: 30),
                index == length - 1
                    ? MyWidget().getRoundBtnWidget(
                        text: MyStrings.complete,
                        f: () async {
                          LocalStorage().prefs.remove(readingTitle.id);
                          Get.back();
                          History history = History(item: 'reading', itemId: readingTitle.id);
                          final readingHistory = User().readingHistory;
                          readingHistory.add(history.toJson());
                          await Database().updateDoc(collection: 'Users', docId: User().id, key: 'readingHistory', value: readingHistory);
                          User().readingHistory.add(history);
                        })
                    : const SizedBox.shrink(),
              ],
            );
          },
          childCount: length,
        ),
      ),
    );
  }

  Widget partContentKo(int index) {
    Reading reading = readings[index];
    final contentKo = reading.content[KO];
    controller.hasFlashcard[index] = LocalStorage().hasFlashcard(itemId: reading.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: MyWidget().getTextWidget(text: (index + 1).toString(), color: MyColors.purple, isBold: true),
            )),
            Obx(() => IconButton(
                onPressed: () {
                  if (controller.hasFlashcard[index]) {
                    FlashCard().removeFlashcard(itemId: reading.id);
                    controller.hasFlashcard[index] = false;
                  } else {
                    FlashCard().addFlashcard(
                        itemId: reading.id,
                        front: reading.content[KO],
                        back: reading.content[fo],
                        audio: 'ReadingAudios_${readingTitle.id}_${reading.id}');
                    controller.hasFlashcard[index] = true;
                  }
                },
                icon: Icon(
                  controller.hasFlashcard[index]
                      ? CupertinoIcons.heart_fill
                      : CupertinoIcons.heart,
                  color: MyColors.purple,
                ))),
            Material(
              child: IconButton(
                icon: const Icon(Icons.volume_up_outlined, color: MyColors.purple),
                onPressed: () {
                  PlayAudio().playReading(readingTitleId: readingTitle.id, readingId: reading.id);
                },
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: MyWidget().getTextWidget(text: contentKo, size: 18, height: 1.8, isKorean: true),
        ),
      ],
    );
  }

  Widget partContentFo(int index) {
    final contentFo = readings[index].content[fo];
    controller.initIsExpanded(readings.length);
    return ExpansionTile(
      onExpansionChanged: (value) {
        controller.setIsExpanded(index, value);
      },
      leading: const Icon(Icons.g_translate_rounded),
      iconColor: MyColors.purple,
      title: const Text(''),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        MyWidget().getTextWidget(text: contentFo, color: MyColors.grey),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget partWords(int index) {
    Reading reading = readings[index];
    List<dynamic> wordKoList = reading.words[KO];
    List<dynamic> wordFoList = reading.words[fo];

    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: wordKoList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const SizedBox(
                  height: 10,
                  child: VerticalDivider(
                    color: MyColors.purple,
                    thickness: 1,
                    width: 18,
                  ),
                ),
                MyWidget().getTextWidget(text: wordKoList[index], isKorean: true, size: 18),
                const Text(' : '),
                MyWidget().getTextWidget(text: wordFoList[index])
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: MyColors.purpleLight,
          child: FutureBuilder(
            future: future,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                readings = [];
                for(dynamic snapshot in snapshot.data) {
                  readings.add(Reading.fromJson(snapshot.data() as Map<String, dynamic>));
                }
                controller.hasFlashcard.value = List.generate(readings.length, (index) => false);
                if(readings.isEmpty) {
                  return Center(
                    child: MyWidget().getTextWidget(
                      text: MyStrings.noReading,
                      color: MyColors.purple,
                      size: 20,
                      isTextAlignCenter: true,
                    ),
                  );
                } else {
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    controller: scrollController,
                    slivers: [
                      sliverAppBar(),
                      sliverList(),
                    ],
                  );
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}
