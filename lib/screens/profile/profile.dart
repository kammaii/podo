import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/items/profile_item.dart';
import 'package:podo/screens/subscribe/subscribe.dart';
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String image = 'assets/images/logo.png';
  String userId = 'User Id';
  List<ProfileItem> items = [
    ProfileItem(Icons.account_circle_rounded, MyStrings.editProfile),
    ProfileItem(Icons.feedback_outlined, MyStrings.feedback),
    ProfileItem(Icons.logout_rounded, MyStrings.logOut),
    ProfileItem(Icons.remove_circle_outline_rounded, MyStrings.removeAccount),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [MyColors.purple, MyColors.green]),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white),
                    child: Center(
                      child: Column(
                        children: [
                          MyWidget().getTextWidget(
                            text: MyStrings.podoPremium,
                            size: 20,
                            color: Colors.white,
                            isBold: true,
                          ),
                          const SizedBox(height: 15),
                          MyWidget().getRoundBtnWidget(
                            isRequest: false,
                            text: MyStrings.startFreeTrial,
                            bgColor: MyColors.purple,
                            fontColor: Colors.white,
                            f: () {
                              Get.to(const Subscribe());
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      MyWidget().getCircleImageWidget(
                        image: image,
                        size: 100,
                      ),
                      const SizedBox(height: 10),
                      MyWidget().getTextWidget(
                        text: userId,
                        size: 25,
                        color: Colors.black,
                        isBold: true,
                      ),
                      const SizedBox(height: 30),
                      ExpansionPanelList(
                        expansionCallback: (index, isExpanded) {
                          setState(() {
                            closePanels();
                            items[index].isExpanded = !isExpanded;
                          });
                        },
                        children: [
                          // Edit Profile
                          getExpansionPanel(
                              items[0],
                              Column(
                                children: [
                                  getTextField(MyStrings.name),
                                  getTextField(MyStrings.email),
                                  getTextField(MyStrings.password),
                                  getTextField(MyStrings.passwordConfirm),
                                ],
                              )),

                          // Feedback
                          getExpansionPanel(
                              items[1],
                              ListTile(
                                  title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyWidget().getTextWidget(
                                    text: MyStrings.feedbackDetail,
                                    size: 15,
                                    color: MyColors.purple,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: MyWidget()
                                              .getTextFieldWidget(hint: MyStrings.feedbackHint, fontSize: 15),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        MyWidget().getRoundBtnWidget(
                                          isRequest: false,
                                          text: MyStrings.send,
                                          bgColor: MyColors.purple,
                                          fontColor: Colors.white,
                                          f: () {},
                                          innerVerticalPadding: 10,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ))),

                          // Logout
                          getExpansionPanel(
                              items[2],
                              ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyWidget().getTextWidget(
                                      text: MyStrings.logOutDetail,
                                      size: 15,
                                      color: MyColors.purple,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: MyWidget().getRoundBtnWidget(
                                            isRequest: false,
                                            text: MyStrings.yes,
                                            bgColor: MyColors.purple,
                                            fontColor: Colors.white,
                                            f: () {
                                              //todo: 로그아웃
                                            },
                                            innerVerticalPadding: 10,
                                          )),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: MyWidget().getRoundBtnWidget(
                                            isRequest: false,
                                            text: MyStrings.cancel,
                                            bgColor: MyColors.red,
                                            fontColor: Colors.white,
                                            f: () {
                                              setState(() {
                                                closePanels();
                                              });
                                            },
                                            innerVerticalPadding: 10,
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),

                          // Remove account
                          getExpansionPanel(
                              items[3],
                              ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyWidget().getTextWidget(
                                        text: MyStrings.removeDetail, size: 15, color: MyColors.purple),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: MyWidget().getRoundBtnWidget(
                                            isRequest: false,
                                            text: MyStrings.yes,
                                            bgColor: MyColors.purple,
                                            fontColor: Colors.white,
                                            f: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => CupertinoAlertDialog(
                                                  title: MyWidget().getTextWidget(
                                                    text: MyStrings.areYouSure,
                                                    size: 18,
                                                    color: Colors.black,
                                                  ),
                                                  content: MyWidget().getTextWidget(
                                                    text: MyStrings.removeDetail2,
                                                    size: 15,
                                                    color: MyColors.red,
                                                    isBold: true,
                                                  ),
                                                  actions: [
                                                    CupertinoDialogAction(
                                                      child: const Text(MyStrings.yes),
                                                      onPressed: () {
                                                        //todo: 계정삭제
                                                      },
                                                    ),
                                                    CupertinoDialogAction(
                                                      child: const Text(MyStrings.cancel),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        setState(() {
                                                          closePanels();
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            innerVerticalPadding: 10,
                                          )),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: MyWidget().getRoundBtnWidget(
                                            isRequest: false,
                                            text: MyStrings.cancel,
                                            bgColor: MyColors.red,
                                            fontColor: Colors.white,
                                            f: () {
                                              setState(() {
                                                closePanels();
                                              });
                                            },
                                            innerVerticalPadding: 10,
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  closePanels() {
    for (ProfileItem item in items) {
      item.isExpanded = false;
    }
  }
}

Widget getTextField(String title) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: MyWidget().getTextWidget(
            text: title,
            size: 15,
            color: Colors.black,
            isBold: true,
          ),
        ),
        const SizedBox(height: 5),
        MyWidget().getTextFieldWidget(hint: '', fontSize: 15),
      ],
    ),
  );
}

ExpansionPanel getExpansionPanel(ProfileItem item, Widget body) {
  return ExpansionPanel(
      canTapOnHeader: true,
      isExpanded: item.isExpanded,
      headerBuilder: (context, isExpanded) {
        return ListTile(
          leading: Icon(
            item.icon,
            color: MyColors.purple,
            size: 30,
          ),
          title: MyWidget().getTextWidget(
            text: item.title,
            size: 18,
            color: Colors.black,
          ),
        );
      },
      body: body);
}
