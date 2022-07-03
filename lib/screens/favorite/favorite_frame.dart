import 'package:flutter/material.dart';
import 'package:podo/common_widgets/my_widget.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class FavoriteFrame extends StatefulWidget {
  const FavoriteFrame({Key? key}) : super(key: key);

  @override
  _FavoriteFrameState createState() => _FavoriteFrameState();
}

class _FavoriteFrameState extends State<FavoriteFrame> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  List<String> favoriteList = [];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    favoriteList = [];
    // Favorite favorite =
    //     Favorite(id: 'id000', korean: '사과', english: 'apple', pronunciation: '[사과]', audio: 'audioString');
    // favoriteList.add(favorite);

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  MyWidget().getSearchWidget(
                    focusNode: _focusNode,
                    controller: _controller,
                    hint: MyStrings.favoriteSearchHint,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: MyWidget().getTextWidget(text: MyStrings.sentences, size: 15, color: Colors.black),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: favoriteList.length,
                      itemBuilder: (BuildContext context, int index) {
                        // String korean = favoriteList[index].korean;
                        // String audio = favoriteList[index].audio;
                        return getFavoriteItem();
                      },
                    ),
                  )
                ],
              ),
            ),
            Padding(
              // Ask a question 버튼
              padding: const EdgeInsets.only(bottom: 15),
              child: Container(
                alignment: Alignment.bottomCenter,
                child: MyWidget().getRoundBtnWithAlert(
                  isRequest: false,
                  text: MyStrings.review,
                  bgColor: MyColors.purple,
                  fontColor: Colors.white,
                  f: () {
                    setState(() {});
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getFavoriteItem() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MyWidget()
                  .getTextWidget(text: '사과는 맛있어요ㅓ이닐너ㅣㅏㅇ러니ㄴㅁ하ㅣ넣나ㅣㅓ히ㅏ넣나ㅣ.', size: 15, color: Colors.black),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(
                Icons.volume_up_rounded,
                color: MyColors.purple,
              ),
              onPressed: () {},
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
