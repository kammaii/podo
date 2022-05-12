import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:podo/common_widgets/my_widget.dart';
import 'package:podo/screens/profile/profile_item.dart';
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
                        gradient: const LinearGradient(
                            colors: [MyColors.purple, MyColors.green]),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white),
                    child: Center(
                      child: Column(
                        children: [
                          MyWidget().getTextWidget(
                              MyStrings.podoPremium, 20, Colors.white,
                              isBold: true),
                          const SizedBox(height: 15),
                          MyWidget().getRoundBtnWidget(
                              false,
                              MyStrings.startFreeTrial,
                              MyColors.purple,
                              Colors.white,
                              () {
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
                      MyWidget().getCircleImageWidget(image, 100),
                      const SizedBox(height: 10),
                      MyWidget().getTextWidget(userId, 25, Colors.black, isBold: true),
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
                          getExpansionPanel(items[0], Column(
                            children: [
                              getTextField(MyStrings.name),
                              getTextField(MyStrings.email),
                              getTextField(MyStrings.password),
                              getTextField(MyStrings.passwordConfirm),
                            ],
                          )),

                          // Feedback
                          getExpansionPanel(items[1], ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyWidget().getTextWidget(MyStrings.feedbackDetail, 15, MyColors.purple),
                                  const SizedBox(height: 10,),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: MyWidget().getTextFieldWidget(MyStrings.feedbackHint, 15),
                                        ),
                                        const SizedBox(width: 10,),
                                        MyWidget().getRoundBtnWidget(false, MyStrings.send, MyColors.purple, Colors.white, (){}, innerVerticalPadding: 10)
                                      ],
                                    ),
                                  ),
                                ],
                              )
                          )),

                          // Logout
                          getExpansionPanel(items[2], ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyWidget().getTextWidget(MyStrings.logOutDetail, 15, MyColors.purple),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      Expanded(child: MyWidget().getRoundBtnWidget(false, MyStrings.yes, MyColors.purple, Colors.white, (){
                                        //todo: 로그아웃
                                      }, innerVerticalPadding: 10)),
                                      const SizedBox(width: 10,),
                                      Expanded(child: MyWidget().getRoundBtnWidget(false, MyStrings.cancel, MyColors.red, Colors.white, (){
                                        setState(() {
                                          closePanels();
                                        });
                                      }, innerVerticalPadding: 10)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),

                          // Remove account
                          getExpansionPanel(items[3], ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyWidget().getTextWidget(MyStrings.removeDetail, 15, MyColors.purple),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      Expanded(child: MyWidget().getRoundBtnWidget(false, MyStrings.yes, MyColors.purple, Colors.white, (){
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                            CupertinoAlertDialog(
                                              title: MyWidget().getTextWidget(MyStrings.areYouSure, 18, Colors.black),
                                              content: MyWidget().getTextWidget(MyStrings.removeDetail2, 15, MyColors.red, isBold: true),
                                              actions: [
                                                CupertinoDialogAction(child: const Text(MyStrings.yes), onPressed: (){
                                                  //todo: 계정삭제
                                                },),
                                                CupertinoDialogAction(child: const Text(MyStrings.cancel), onPressed: (){
                                                  Navigator.pop(context);
                                                  setState(() {
                                                    closePanels();
                                                  });
                                                },),
                                              ],
                                            ),
                                        );
                                      }, innerVerticalPadding: 10)),
                                      const SizedBox(width: 10,),
                                      Expanded(child: MyWidget().getRoundBtnWidget(false, MyStrings.cancel, MyColors.red, Colors.white, (){
                                        setState(() {
                                          closePanels();
                                        });
                                      }, innerVerticalPadding: 10)),
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
    for(ProfileItem item in items) {
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
          child: MyWidget().getTextWidget(title, 15, Colors.black, isBold: true),
        ),
        const SizedBox(height: 5),
        MyWidget().getTextFieldWidget('', 15),
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
          leading: Icon(item.icon, color: MyColors.purple, size: 30,),
          title: MyWidget().getTextWidget(item.title, 18, Colors.black),
        );
      },
      body: body
  );
}

