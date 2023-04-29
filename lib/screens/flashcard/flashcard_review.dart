import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

enum SingingCharacter { listenAndRepeat, speakAndListen }

class FlashcardReview extends StatefulWidget {
  const FlashcardReview({Key? key}) : super(key: key);

  @override
  _FlashcardReviewState createState() => _FlashcardReviewState();
}

class _FlashcardReviewState extends State<FlashcardReview> {
  SingingCharacter? _character = SingingCharacter.listenAndRepeat;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: MyColors.purple,
          ),
          title: MyWidget().getTextWidget(
            text: MyStrings.title,
            size: 18,
            color: MyColors.purple,
          ),
        ),
        body: Column(
          children: [
            LinearPercentIndicator(
              animateFromLastPercent: true,
              animation: true,
              lineHeight: 3.0,
              percent: 0.5,
              backgroundColor: MyColors.navyLight,
              progressColor: MyColors.purple,
            ),
            const SizedBox(height: 10),
            Column(
              children: <Widget>[
                ListTile(
                  title: MyWidget().getTextWidget(
                    text: MyStrings.listenAndRepeat,
                    size: 15,
                    color: MyColors.purple,
                  ),
                  leading: Radio<SingingCharacter>(
                    activeColor: MyColors.purple,
                    value: SingingCharacter.listenAndRepeat,
                    groupValue: _character,
                    onChanged: (SingingCharacter? value) {
                      setState(() {
                        _character = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: MyWidget().getTextWidget(
                    text: MyStrings.speakAndListen,
                    size: 15,
                    color: MyColors.purple,
                  ),
                  leading: Radio<SingingCharacter>(
                    activeColor: MyColors.purple,
                    value: SingingCharacter.speakAndListen,
                    groupValue: _character,
                    onChanged: (SingingCharacter? value) {
                      setState(() {
                        _character = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyWidget().getTextWidget(
                          text: '비가와요',
                          size: 30,
                          color: Colors.black,
                        ),
                        MyWidget().getTextWidget(
                          text: 'It\'s rainy',
                          size: 20,
                          color: MyColors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(FontAwesomeIcons.play),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: MyWidget().getRoundBtnWidget(
                      isRequest: false,
                      text: MyStrings.next,
                      bgColor: MyColors.purple,
                      fontColor: Colors.white,
                      f: () {},
                      horizontalPadding: 20,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
