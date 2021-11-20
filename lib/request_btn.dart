import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'my_colors.dart';

class RequestBtn {
  Widget getRequestBtn(String text) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 교정 요청 버튼
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                primary: MyColors.grey),
            onPressed: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    height: 30,
                    child: VerticalDivider(
                      color: Colors.white,
                      thickness: 1,
                      width: 20,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('consume'),
                      Row(
                        children: const [
                          Icon(CupertinoIcons.ticket),
                          SizedBox(width: 5),
                          Text('2'),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          // todo:
          // if(티켓이 충분할때)
          // const SizedBox(height: 20),
          // 티켓 부족 알림
          Container(
            decoration: const BoxDecoration(
              color: MyColors.pink,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '* Not enough tickets',
                  style: TextStyle(
                      color: MyColors.purple, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'How to get tickets?',
                    style: TextStyle(
                        color: MyColors.red,
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                        decorationThickness: 2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
