import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info/package_info.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/languages.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_date_format.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/login/credentials.dart';
import 'package:podo/screens/my_page/feedback.dart' as fb;
import 'package:podo/screens/my_page/my_page_controller.dart';
import 'package:podo/screens/my_page/user.dart' as user;
import 'package:podo/values/my_colors.dart';

class MyPageItem {
  late IconData icon;
  late String title;
  bool isExpanded = false;

  MyPageItem(this.icon, this.title);
}

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  List<MyPageItem> items = [
    MyPageItem(Icons.account_circle_rounded, tr('editName')),
    MyPageItem(CupertinoIcons.globe, tr('language')),
    MyPageItem(Icons.feedback_outlined, tr('feedback')),
    MyPageItem(Icons.logout_rounded, tr('logOut')),
    MyPageItem(Icons.remove_circle_outline_rounded, tr('removeAccount')),
  ];
  List<String> userTier = ['New', 'Basic', 'Premium', 'Trial'];
  FirebaseAuth auth = FirebaseAuth.instance;
  String signupDate = '';
  String userId = '';
  String userEmail = '';
  String? userName;
  User? currentUser;
  String feedback = '';
  List<String> language = [
    tr('english'),
    tr('spanish'),
    tr('french'),
    tr('german'),
    tr('portuguese'),
    tr('indonesian'),
    tr('russian')
  ];
  late bool hasUserName;
  late ResponsiveSize rs;

  void removeUserAccount(UserCredential? userCredential) {
    if (userCredential != null) {
      User user = userCredential.user!;
      Database().deleteDoc(
          collection: 'Users',
          docId: user.uid);
      user.delete().then((value) =>
          print('User deleted'));
    } else {
      MyWidget().showSnackbar(rs, title: 'Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.find<MyPageController>();
    rs = ResponsiveSize(context);
    feedback = '';
    currentUser = auth.currentUser;
    print(currentUser);

    if (currentUser != null) {
      DateTime? date = auth.currentUser?.metadata.creationTime;
      userId = currentUser!.uid ?? '';
      userEmail = currentUser!.email ?? '';
      userName = user.User().name;
      userName == null || userName!.isEmpty ? hasUserName = false : hasUserName = true;
      if (date != null) {
        signupDate = MyDateFormat().getDateFormat(date);
      }
    }

    int userStatus = user.User().status;
    String? expiredDate;
    if (userStatus == 3) {
      expiredDate = MyDateFormat().getDateFormat(user.User().trialEnd!);
    } else if (userStatus == 2) {
      expiredDate = user.User().expirationDate;
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(rs.getSize(20)),
        child: Column(
          children: [
            user.User().status == 0 || user.User().status == 1
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      backgroundColor: Colors.transparent,
                    ),
                    onPressed: () {
                      Get.toNamed('/premiumMain');
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: rs.getSize(13), horizontal: rs.getSize(30)),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [MyColors.purple, MyColors.green]),
                          borderRadius: BorderRadius.circular(30)),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.crown, color: Colors.white, size: rs.getSize(20)),
                          Expanded(
                            child: Center(
                              child: MyWidget().getTextWidget(
                                rs,
                                text: tr('getPremium'),
                                size: 20,
                                color: Colors.white,
                                isBold: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            SizedBox(height: rs.getSize(20)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/podo.png', width: rs.getSize(30), height: rs.getSize(30)),
                        const SizedBox(width: 10),
                        MyWidget().getTextWidget(
                          rs,
                          text: hasUserName ? userName : tr('unNamed'),
                          size: hasUserName ? 20 : 15,
                          color: hasUserName ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                          isBold: true,
                          isKorean: true,
                        ),
                        MyWidget().getTextWidget(
                          rs,
                          text: ', 안녕하세요?',
                          size: 20,
                          color: Theme.of(context).primaryColor,
                          isBold: true,
                          isKorean: true,
                        ),
                      ],
                    ),
                    SizedBox(height: rs.getSize(10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyWidget()
                            .getTextWidget(rs, text: 'Dark Mode', color: Theme.of(context).secondaryHeaderColor),
                        const SizedBox(width: 10),
                        GetBuilder<MyPageController>(
                          builder: (controller) {
                            return ToggleButtons(
                              isSelected: controller.modeToggle,
                              onPressed: (int index) {
                                controller.changeMode(index);
                              },
                              constraints: BoxConstraints(minHeight: rs.getSize(28), minWidth: rs.getSize(50)),
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              selectedBorderColor: Theme.of(context).canvasColor,
                              selectedColor: Theme.of(context).cardColor,
                              fillColor: Theme.of(context).canvasColor,
                              color: Theme.of(context).canvasColor,
                              children: [
                                Text('on', style: TextStyle(fontSize: rs.getSize(15))),
                                Text('off', style: TextStyle(fontSize: rs.getSize(15))),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    Theme(
                      data: Theme.of(context).copyWith(
                        highlightColor: MyColors.navyLight,
                      ),
                      child: ExpansionPanelList(
                        expansionCallback: (index, isExpanded) {
                          setState(() {
                            feedback = '';
                            closePanels();
                            if (Platform.isIOS) {
                              items[index].isExpanded = !isExpanded;
                            } else {
                              items[index].isExpanded = isExpanded;
                            }
                          });
                        },
                        children: [
                          // Edit Name
                          getExpansionPanel(
                              items[0],
                              Padding(
                                padding: EdgeInsets.all(rs.getSize(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: MyWidget().getTextWidget(
                                        rs,
                                        text: tr('name'),
                                        color: Theme.of(context).secondaryHeaderColor,
                                        isBold: true,
                                      ),
                                    ),
                                    SizedBox(height: rs.getSize(5)),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: MyWidget().getTextFieldWidget(
                                            context,
                                            rs,
                                            controller: TextEditingController(text: userName),
                                            onChanged: (text) {
                                              userName = text;
                                            },
                                          ),
                                        ),
                                        SizedBox(width: rs.getSize(10)),
                                        MyWidget().getRoundBtnWidget(rs,
                                            text: tr('edit'),
                                            verticalPadding: 8,
                                            horizontalPadding: 3,
                                            textSize: 15, f: () async {
                                          try {
                                            if (currentUser != null) {
                                              closePanels();
                                              await currentUser!.updateDisplayName(userName);
                                              await Database().updateDoc(
                                                  collection: 'Users',
                                                  docId: currentUser!.uid,
                                                  key: 'name',
                                                  value: userName);
                                              setState(() {
                                                user.User().name = userName ?? '';
                                                MyWidget().showSnackbar(rs, title: tr('nameChanged'));
                                              });
                                            }
                                          } catch (e) {
                                            MyWidget().showSnackbar(rs, title: tr('error'), message: e.toString());
                                          }
                                        },
                                            bgColor: Theme.of(context).canvasColor,
                                            fontColor: Theme.of(context).cardColor)
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              subTitle: hasUserName ? null : 'Please set your name'),

                          // Language
                          getExpansionPanel(
                            items[1],
                            ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyWidget().getTextWidget(
                                    rs,
                                    text: tr('shouldRestart'),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(height: rs.getSize(10)),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: rs.getSize(8)),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                              side: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                                              backgroundColor: Theme.of(context).cardColor),
                                          onPressed: () async {
                                            String lang = Languages().fos[index];
                                            user.User().language = lang;
                                            EasyLocalization.of(context)!.setLocale(Locale(lang));
                                            await Database().updateDoc(
                                                collection: 'Users',
                                                docId: user.User().id,
                                                key: 'language',
                                                value: lang);
                                            MyWidget().showSnackbarWithPodo(rs,
                                                title: tr('languageChanged'),
                                                content: tr('shouldRestart'),
                                                duration: 5000);
                                            setState(() {
                                              closePanels();
                                            });
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: rs.getSize(13)),
                                            child: Text(language[index],
                                                style: TextStyle(
                                                    color: Theme.of(context).primaryColor,
                                                    fontSize: rs.getSize(15))),
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: language.length,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Feedback
                          getExpansionPanel(
                              items[2],
                              ListTile(
                                  title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyWidget().getTextWidget(
                                    rs,
                                    text: tr('feedbackDetail'),
                                    color: Theme.of(context).primaryColor,
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
                                          child: MyWidget().getTextFieldWidget(context, rs,
                                              hint: tr('feedbackHint'),
                                              controller: TextEditingController(text: feedback),
                                              onChanged: (text) {
                                            feedback = text;
                                          }),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        MyWidget().getRoundBtnWidget(
                                          rs,
                                          text: tr('send'),
                                          verticalPadding: 8,
                                          horizontalPadding: 3,
                                          textSize: 15,
                                          bgColor: Theme.of(context).canvasColor,
                                          fontColor: Theme.of(context).cardColor,
                                          f: () async {
                                            try {
                                              if (feedback.isNotEmpty) {
                                                fb.Feedback userFeedback = fb.Feedback();
                                                userFeedback.userId = userId;
                                                userFeedback.email = userEmail;
                                                userFeedback.message = feedback;
                                                await Database()
                                                    .setDoc(collection: 'Feedbacks', doc: userFeedback);
                                                MyWidget().showSnackbar(rs, title: tr('thanksFeedback'));
                                              }
                                            } catch (e) {
                                              if (e is PlatformException && e.code == "not_available") {
                                                MyWidget()
                                                    .showSnackbar(rs, title: tr('error'), message: e.toString());
                                              }
                                            }
                                            setState(() {
                                              closePanels();
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ))),

                          // Logout
                          getExpansionPanel(
                              items[3],
                              ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyWidget().getTextWidget(
                                      rs,
                                      text: tr('logOutDetail'),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: MyWidget().getRoundBtnWidget(
                                            rs,
                                            text: tr('yes'),
                                            textSize: 15,
                                            bgColor: Theme.of(context).canvasColor,
                                            fontColor: Theme.of(context).cardColor,
                                            f: () async {
                                              LocalStorage().isInit = false;
                                              await auth.signOut();
                                              print('User logged out');
                                            },
                                            verticalPadding: 10,
                                          )),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: MyWidget().getRoundBtnWidget(
                                            rs,
                                            text: tr('cancel'),
                                            textSize: 15,
                                            bgColor: Theme.of(context).focusColor,
                                            fontColor: Theme.of(context).cardColor,
                                            f: () {
                                              setState(() {
                                                closePanels();
                                              });
                                            },
                                            verticalPadding: 10,
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),

                          // Remove account
                          getExpansionPanel(
                              items[4],
                              ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyWidget().getTextWidget(
                                      rs,
                                      text: tr('removeDetail'),
                                      color: Theme.of(context).focusColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: MyWidget().getRoundBtnWidget(
                                            rs,
                                            text: tr('yes'),
                                            textSize: 15,
                                            bgColor: Theme.of(context).canvasColor,
                                            fontColor: Theme.of(context).cardColor,
                                            f: () {
                                              Get.dialog(
                                                AlertDialog(
                                                  backgroundColor: Theme.of(context).cardColor,
                                                  title: MyWidget().getTextWidget(
                                                    rs,
                                                    text: tr('areYouSure'),
                                                    size: 20,
                                                    color: Theme.of(context).secondaryHeaderColor,
                                                  ),
                                                  content: MyWidget().getTextWidget(
                                                    rs,
                                                    text: tr('removeDetail2'),
                                                    color: Theme.of(context).focusColor,
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: MyWidget().getTextWidget(rs,
                                                          text: tr('yes'),
                                                          color: Theme.of(context).secondaryHeaderColor),
                                                      onPressed: () async {
                                                        User? user = auth.currentUser;
                                                        if (user != null) {
                                                          String providerId = '';
                                                          for (UserInfo providerData in user.providerData) {
                                                            providerId = providerData.providerId;
                                                          }
                                                          print('PROVIDER: $providerId');
                                                          Get.back();

                                                          UserCredential? userCredential;
                                                          switch (providerId) {
                                                            case 'password':
                                                              String password = '';
                                                              Get.dialog(AlertDialog(
                                                                title: MyWidget().getTextFieldWidget(context, rs,
                                                                    hint: tr('passwordAgain'), onChanged: (value) {
                                                                      password = value;
                                                                    }),
                                                                actions: [
                                                                  TextButton(
                                                                    child: Text(tr('send'),
                                                                        style: TextStyle(
                                                                            fontSize: rs.getSize(15),
                                                                            color: Theme
                                                                                .of(context)
                                                                                .secondaryHeaderColor)),
                                                                    onPressed: () async {
                                                                      Get.back();
                                                                      try {
                                                                        userCredential = await user.reauthenticateWithCredential(
                                                                          EmailAuthProvider.credential(
                                                                              email: user.email!,
                                                                              password: password),
                                                                        );
                                                                        removeUserAccount(userCredential);
                                                                      } catch (e) {
                                                                        showErrorSnackbar(e);
                                                                      }
                                                                    },
                                                                  )
                                                                ],
                                                              ));
                                                              break;

                                                            case 'google.com':
                                                              userCredential = await Credentials().getGoogleCredential();
                                                              removeUserAccount(userCredential);
                                                              break;

                                                            case 'apple.com':
                                                              userCredential = await Credentials().getAppleCredential();
                                                              removeUserAccount(userCredential);
                                                              break;
                                                          }


                                                        }
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: MyWidget().getTextWidget(rs,
                                                          text: tr('cancel'),
                                                          color: Theme.of(context).secondaryHeaderColor),
                                                      onPressed: () {
                                                        Get.back();
                                                        setState(() {
                                                          closePanels();
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            verticalPadding: 10,
                                          )),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: MyWidget().getRoundBtnWidget(
                                            rs,
                                            text: tr('cancel'),
                                            textSize: 15,
                                            bgColor: Theme.of(context).focusColor,
                                            fontColor: Theme.of(context).cardColor,
                                            f: () {
                                              setState(() {
                                                closePanels();
                                              });
                                            },
                                            verticalPadding: 10,
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FutureBuilder(
                              future: PackageInfo.fromPlatform(),
                              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                if (snapshot.hasData) {
                                  return MyWidget().getTextWidget(
                                    rs,
                                    text: 'v${snapshot.data.version}',
                                    color: Theme.of(context).disabledColor,
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                            MyWidget().getTextWidget(
                              rs,
                              text: user.User().email,
                              color: Theme.of(context).disabledColor,
                            ),
                            MyWidget().getTextWidget(
                              rs,
                              text: 'Sign up $signupDate',
                              color: Theme.of(context).disabledColor,
                            ),
                            Row(
                              children: [
                                MyWidget().getTextWidget(
                                  rs,
                                  text: '${userTier[user.User().status]} Mode',
                                  color: Theme.of(context).disabledColor,
                                ),
                                expiredDate != null
                                    ? MyWidget().getTextWidget(rs,
                                        text: ': ~ $expiredDate', color: Theme.of(context).disabledColor)
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: rs.getSize(50)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  closePanels() {
    for (MyPageItem item in items) {
      item.isExpanded = false;
    }
  }

  void showErrorSnackbar(Object e) {
    Get.snackbar(
      'Error',
      e.toString(),
      colorText: Theme.of(context).cardColor,
      backgroundColor: Theme.of(context).focusColor,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
    );
    print('ERROR: $e');
  }

  ExpansionPanel getExpansionPanel(MyPageItem item, Widget body, {String? subTitle}) {
    return ExpansionPanel(
        canTapOnHeader: true,
        isExpanded: item.isExpanded,
        headerBuilder: (context, isExpanded) {
          return subTitle == null
              ? Padding(
                  padding: EdgeInsets.all(rs.getSize(8)),
                  child: ListTile(
                    leading: Icon(
                      item.icon,
                      color: Theme.of(context).canvasColor,
                      size: rs.getSize(30),
                    ),
                    title: MyWidget().getTextWidget(
                      rs,
                      text: item.title,
                      size: 18,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(rs.getSize(8)),
                  child: ListTile(
                      leading: Icon(
                        item.icon,
                        color: Theme.of(context).primaryColor,
                        size: rs.getSize(30),
                      ),
                      title: MyWidget().getTextWidget(
                        rs,
                        text: item.title,
                        size: 18,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      subtitle: MyWidget().getTextWidget(
                        rs,
                        text: subTitle,
                        color: Theme.of(context).focusColor,
                      )),
                );
        },
        body: body);
  }
}
