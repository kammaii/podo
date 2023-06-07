import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/play_audio.dart';
import 'package:podo/screens/flashcard/flashcard.dart';
import 'package:podo/screens/reading/reading.dart';
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
  Reading reading = Get.arguments;
  String fo = 'en'; //todo: 기기 설정에 따라 바뀌게 하기
  String sampleImage = 'assets/images/course_hangul.png';
  final KO = 'ko';
  final cardBorderRadius = 8.0;
  bool isImageVisible = true;
  late AnimationController animationController;
  late Animation<double> animation;
  double currentScrollPercent = 0;
  double scrollPosition = 0;

  @override
  void dispose() {
    super.dispose();
    if (currentScrollPercent > 0.1 && currentScrollPercent < 0.9) {
      LocalStorage().prefs.setDouble(reading.id, scrollPosition);
    } else {
      LocalStorage().prefs.remove(reading.id);
    }
    scrollController.dispose();
    PlayAudio().reset();
  }

  @override
  void initState() {
    super.initState();
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

    double? position = LocalStorage().prefs.getDouble(reading.id);
    print(position);
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
        text: '${reading.title[KO]}',
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
              tag: 'readingImage:${reading.id}',
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
                  Text('${reading.content[KO].length}'),
                  const SizedBox(width: 20),
                  const Text('|'),
                  const SizedBox(width: 20),
                  letterContainer('W'),
                  const SizedBox(width: 10),
                  Text('${reading.content[KO].length}'),
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
    int length = reading.content[KO].length;
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
                const Divider(),
                const SizedBox(height: 30),
                index == length - 1
                    ? MyWidget().getRoundBtnWidget(
                        text: MyStrings.complete,
                        bgColor: MyColors.purple,
                        fontColor: Colors.white,
                        f: () {
                          LocalStorage().prefs.remove(reading.id);
                          Get.back();
                          //todo: User().readingRecord 에 추가
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
    final contentKo = reading.content[KO][index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: MyWidget().getTextWidget(text: (index+1).toString(), color: MyColors.purple, isBold: true),
            )),
            Material(
              child: IconButton(
                icon: const Icon(Icons.star_outline_rounded, color: MyColors.purple),
                onPressed: () {
                  FlashCard flashcard = FlashCard();
                  flashcard.front = contentKo;
                  flashcard.back = reading.content[fo][index];
                  flashcard.audio = 'ReadingAudios_${reading.id}_$index';
                  Database().setFlashcard(flashCard: flashcard);
                },
              ),
            ),
            Material(
              child: IconButton(
                icon: const Icon(Icons.volume_up_outlined, color: MyColors.purple),
                onPressed: () {
                  PlayAudio().playReading(readingId: reading.id, index: index);
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
    final contentFo = reading.content[fo][index];
    return ExpansionTile(
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
    final wordList = reading.words[KO];
    final contentKo = reading.content[KO][index];
    List<String> wordKoList = [];
    List<String> wordFoList = [];

    for (int i = 0; i < wordList.length; i++) {
      String word = wordList[i];

      String insideText = '';
      String outsideText = '';

      int startIdx = word.indexOf('(');
      int endIdx = word.indexOf(')');

      if (startIdx != -1 && endIdx != -1 && startIdx < endIdx) {
        insideText = word.substring(startIdx + 1, endIdx);
        outsideText = word.substring(0, startIdx) + word.substring(endIdx + 1);
      } else {
        insideText = word;
        outsideText = word;
      }

      if (contentKo.contains(outsideText)) {
        wordKoList.add(insideText);
        wordFoList.add(reading.words[fo][i]);
      }
    }

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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            controller: scrollController,
            slivers: [
              sliverAppBar(),
              sliverList(),
            ],
          ),
        ),
      ),
    );
  }
}
