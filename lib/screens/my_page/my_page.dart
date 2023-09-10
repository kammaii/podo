import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/languages.dart';
import 'package:podo/common/local_storage.dart';
import 'package:podo/common/my_date_format.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/my_page/feedback.dart' as fb;
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

  @override
  Widget build(BuildContext context) {
    feedback = '';
    currentUser = auth.currentUser;
    if (currentUser != null) {
      DateTime? date = auth.currentUser?.metadata.lastSignInTime;
      userId = currentUser!.uid ?? '';
      userEmail = currentUser!.email ?? '';
      userName = currentUser!.displayName;
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

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              user.User().status == 1
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        backgroundColor: Colors.transparent,
                      ),
                      onPressed: () {
                        Get.toNamed('/premiumMain');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 13, horizontal: 30),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [MyColors.purple, MyColors.green]),
                            borderRadius: BorderRadius.circular(30)),
                        child: Row(
                          children: [
                            const Icon(FontAwesomeIcons.crown,
                                color: Colors.white),
                            Expanded(
                              child: Center(
                                child: MyWidget().getTextWidget(
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
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/images/podo.png',
                              width: 30, height: 30),
                          const SizedBox(width: 10),
                          MyWidget().getTextWidget(
                            text:
                                hasUserName ? user.User().name : tr('unNamed'),
                            size: hasUserName ? 20 : 15,
                            color:
                                hasUserName ? MyColors.purple : MyColors.grey,
                            isBold: true,
                            isKorean: true,
                          ),
                          MyWidget().getTextWidget(
                            text: ', 안녕하세요?',
                            size: 20,
                            color: MyColors.purple,
                            isBold: true,
                            isKorean: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      MyWidget().getTextWidget(
                        text: user.User().email,
                        color: MyColors.purple,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          MyWidget().getTextWidget(
                            text: userTier[user.User().status],
                            color: MyColors.purple,
                          ),
                          expiredDate != null
                              ? MyWidget().getTextWidget(
                                  text: ': ~ $expiredDate',
                                  color: MyColors.purple)
                              : const SizedBox.shrink(),
                        ],
                      ),
                      const SizedBox(height: 30),
                      ExpansionPanelList(
                        expansionCallback: (index, isExpanded) {
                          setState(() {
                            feedback = '';
                            closePanels();
                            items[index].isExpanded = !isExpanded;
                          });
                        },
                        children: [
                          // Edit Name
                          getExpansionPanel(
                              items[0],
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: MyWidget().getTextWidget(
                                        text: tr('name'),
                                        size: 15,
                                        color: Colors.black,
                                        isBold: true,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: MyWidget().getTextFieldWidget(
                                            controller: TextEditingController(
                                                text: userName),
                                            onChanged: (text) {
                                              userName = text;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        MyWidget().getRoundBtnWidget(
                                          text: tr('edit'),
                                          verticalPadding: 8,
                                          horizontalPadding: 3,
                                          f: () async {
                                            try {
                                              if (currentUser != null) {
                                                await currentUser!.updateDisplayName(
                                                    userName);
                                                await Database().updateDoc(
                                                    collection: 'Users',
                                                    docId: currentUser!.uid,
                                                    key: 'name',
                                                    value: userName);
                                                setState(() {
                                                  MyWidget().showSnackbar(
                                                      title: tr('nameChanged'));
                                                });
                                              }
                                            } catch (e) {
                                              MyWidget().showSnackbar(
                                                  title: tr('error'),
                                                  message: e.toString());
                                            }
                                            setState(() {
                                              closePanels();
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              subTitle:
                                  hasUserName ? null : 'Please set your name'),

                          // Language
                          getExpansionPanel(
                            items[1],
                            ListTile(
                              title: Column(
                                children: [
                                  MyWidget().getTextWidget(
                                    text: tr('shouldRestart'),
                                    size: 15,
                                    color: MyColors.purple,
                                  ),
                                  const SizedBox(height: 10),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            side: const BorderSide(
                                                color: MyColors.purple,
                                                width: 1),
                                            backgroundColor: Colors.white),
                                        onPressed: () async {
                                          String lang = Languages().fos[index];
                                          user.User().language = lang;
                                          EasyLocalization.of(context)!
                                              .setLocale(Locale(lang));
                                          await Database().updateDoc(
                                              collection: 'Users',
                                              docId: user.User().id,
                                              key: 'language',
                                              value: lang);
                                          MyWidget().showSnackbarWithPodo(
                                              title: tr('languageChanged'),
                                              content: tr('shouldRestart'),
                                              duration: 5000);
                                          setState(() {
                                            closePanels();
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 13),
                                          child: Text(language[index],
                                              style: const TextStyle(
                                                  color: MyColors.purple)),
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
                                    text: tr('feedbackDetail'),
                                    size: 15,
                                    color: MyColors.purple,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: MyWidget().getTextFieldWidget(
                                              hint: tr('feedbackHint'),
                                              controller: TextEditingController(
                                                  text: feedback),
                                              onChanged: (text) {
                                                feedback = text;
                                              }),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        MyWidget().getRoundBtnWidget(
                                          text: tr('send'),
                                          verticalPadding: 8,
                                          horizontalPadding: 3,
                                          textSize: 15,
                                          f: () async {
                                            try {
                                              if (feedback.isNotEmpty) {
                                                fb.Feedback userFeedback =
                                                    fb.Feedback();
                                                userFeedback.userId = userId;
                                                userFeedback.email = userEmail;
                                                userFeedback.message = feedback;
                                                await Database().setDoc(
                                                    collection: 'Feedbacks',
                                                    doc: userFeedback);
                                                MyWidget().showSnackbar(
                                                    title:
                                                        tr('thanksFeedback'));
                                              }
                                            } catch (e) {
                                              if (e is PlatformException &&
                                                  e.code == "not_available") {
                                                MyWidget().showSnackbar(
                                                    title: tr('error'),
                                                    message: e.toString());
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
                                      text: tr('logOutDetail'),
                                      size: 15,
                                      color: MyColors.purple,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child:
                                                  MyWidget().getRoundBtnWidget(
                                            text: tr('yes'),
                                            textSize: 15,
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
                                              child:
                                                  MyWidget().getRoundBtnWidget(
                                            text: tr('cancel'),
                                            textSize: 15,
                                            bgColor: MyColors.red,
                                            fontColor: Colors.white,
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
                                        text: tr('removeDetail'),
                                        color: MyColors.red),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child:
                                                  MyWidget().getRoundBtnWidget(
                                            text: tr('yes'),
                                            textSize: 15,
                                            f: () {
                                              Get.dialog(
                                                AlertDialog(
                                                  title:
                                                      MyWidget().getTextWidget(
                                                    text: tr('areYouSure'),
                                                    size: 20,
                                                    color: Colors.black,
                                                  ),
                                                  content:
                                                      MyWidget().getTextWidget(
                                                    text: tr('removeDetail2'),
                                                    color: MyColors.red,
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: MyWidget()
                                                          .getTextWidget(
                                                              text: tr('yes')),
                                                      onPressed: () {
                                                        User? user =
                                                            auth.currentUser;
                                                        if (user != null) {
                                                          String providerId =
                                                              '';
                                                          for (UserInfo providerData
                                                              in user
                                                                  .providerData) {
                                                            providerId =
                                                                providerData
                                                                    .providerId;
                                                          }
                                                          print(
                                                              'PROVIDER: $providerId');
                                                          switch (providerId) {
                                                            case 'password':
                                                              String password =
                                                                  '';
                                                              Get.back();
                                                              Get.dialog(
                                                                  AlertDialog(
                                                                title: MyWidget()
                                                                    .getTextFieldWidget(
                                                                        hint: tr(
                                                                            'passwordAgain'),
                                                                        onChanged:
                                                                            (value) {
                                                                          password =
                                                                              value;
                                                                        }),
                                                                actions: [
                                                                  TextButton(
                                                                    child: Text(
                                                                        tr('send')),
                                                                    onPressed:
                                                                        () async {
                                                                      Get.back();
                                                                      try {
                                                                        await user
                                                                            .reauthenticateWithCredential(
                                                                          EmailAuthProvider.credential(
                                                                              email: user.email!,
                                                                              password: password),
                                                                        );
                                                                        await Database().deleteDoc(
                                                                            collection:
                                                                                'Users',
                                                                            docId:
                                                                                auth.currentUser!.uid);
                                                                        await user
                                                                            .delete();
                                                                        print(
                                                                            'User deleted');
                                                                      } catch (e) {
                                                                        showErrorSnackbar(
                                                                            e);
                                                                      }
                                                                    },
                                                                  )
                                                                ],
                                                              ));
                                                              break;

                                                            case 'google.com':
                                                              break;

                                                            case 'apple.com':
                                                              break;
                                                          }
                                                        }
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: MyWidget()
                                                          .getTextWidget(
                                                              text:
                                                                  tr('cancel')),
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
                                              child:
                                                  MyWidget().getRoundBtnWidget(
                                            text: tr('cancel'),
                                            textSize: 15,
                                            bgColor: MyColors.red,
                                            fontColor: Colors.white,
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
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MyWidget().getTextWidget(
                            text: 'Sign up: $signupDate',
                            color: MyColors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
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
    for (MyPageItem item in items) {
      item.isExpanded = false;
    }
  }

  void showErrorSnackbar(Object e) {
    Get.snackbar(
      'Error',
      e.toString(),
      colorText: Colors.white,
      backgroundColor: MyColors.red,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
    );
    print('ERROR: $e');
  }
}

Widget getTextField(
    {required String title,
    required String inputText,
    required Function(String) onChanged,
    required Function onClicked}) {
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
        Row(
          children: [
            Expanded(
              child: MyWidget().getTextFieldWidget(
                controller: TextEditingController(text: inputText),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 10),
            MyWidget().getRoundBtnWidget(
                text: tr('edit'),
                f: onClicked,
                verticalPadding: 8,
                horizontalPadding: 3)
          ],
        ),
      ],
    ),
  );
}

ExpansionPanel getExpansionPanel(MyPageItem item, Widget body,
    {String? subTitle}) {
  return ExpansionPanel(
      canTapOnHeader: true,
      isExpanded: item.isExpanded,
      headerBuilder: (context, isExpanded) {
        return subTitle == null
            ? ListTile(
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
              )
            : ListTile(
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
                subtitle: MyWidget().getTextWidget(
                  text: subTitle,
                  color: MyColors.red,
                ));
      },
      body: body);
}
