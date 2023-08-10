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
import 'package:podo/values/my_strings.dart';

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
    MyPageItem(Icons.account_circle_rounded, MyStrings.editName),
    MyPageItem(CupertinoIcons.globe, MyStrings.language),
    MyPageItem(Icons.feedback_outlined, MyStrings.feedback),
    MyPageItem(Icons.logout_rounded, MyStrings.logOut),
    MyPageItem(Icons.remove_circle_outline_rounded, MyStrings.removeAccount),
  ];
  List<String> userTier = ['New', 'Basic', 'Premium', 'Trial'];
  FirebaseAuth auth = FirebaseAuth.instance;
  String signupDate = '';
  String userId = '';
  String userEmail = '';
  String userName = '';
  User? currentUser;
  String feedback = '';
  List<String> language = [
    MyStrings.english,
    MyStrings.spanish,
    MyStrings.french,
    MyStrings.german,
    MyStrings.portuguese,
    MyStrings.indonesian,
    MyStrings.russian
  ];

  @override
  Widget build(BuildContext context) {
    feedback = '';
    currentUser = auth.currentUser;
    if (currentUser != null) {
      DateTime? date = auth.currentUser?.metadata.lastSignInTime;
      userId = currentUser!.uid ?? '';
      userEmail = currentUser!.email ?? '';
      userName = currentUser!.displayName ?? '';
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        backgroundColor: Colors.transparent,
                      ),
                      onPressed: () {
                        Get.toNamed('/premiumMain');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 30),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [MyColors.purple, MyColors.green]),
                            borderRadius: BorderRadius.circular(30)),
                        child: Row(
                          children: [
                            const Icon(FontAwesomeIcons.crown, color: Colors.white),
                            Expanded(
                              child: Center(
                                child: MyWidget().getTextWidget(
                                  text: MyStrings.getPremium,
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
                          MyWidget().getTextWidget(
                            text: MyStrings.myPage,
                            size: 20,
                            color: MyColors.purple,
                            isBold: true,
                          ),
                          const SizedBox(width: 20),
                          MyWidget().getTextWidget(
                            text: user.User().email,
                            color: MyColors.purple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          MyWidget().getTextWidget(
                            text: userTier[user.User().status],
                            color: MyColors.grey,
                          ),
                          expiredDate != null
                              ? MyWidget().getTextWidget(text: ': ~ $expiredDate', color: MyColors.grey)
                              : const SizedBox.shrink(),
                        ],
                      ),
                      MyWidget().getTextWidget(
                        text: 'Sign up: $signupDate',
                        color: MyColors.grey,
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
                          // Edit Profile
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
                                        text: MyStrings.name,
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
                                            controller: TextEditingController(text: userName),
                                            onChanged: (text) {
                                              userName = text;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        MyWidget().getRoundBtnWidget(
                                          text: MyStrings.edit,
                                          verticalPadding: 8,
                                          horizontalPadding: 3,
                                          f: () async {
                                            try {
                                              if (currentUser != null) {
                                                currentUser!.updateDisplayName(userName);
                                                await Database().updateDoc(
                                                    collection: 'Users',
                                                    docId: currentUser!.uid,
                                                    key: 'name',
                                                    value: userName);
                                                MyWidget().showSnackbar(title: MyStrings.nameChanged);
                                              }
                                            } catch (e) {
                                              MyWidget()
                                                  .showSnackbar(title: MyStrings.error, message: e.toString());
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
                              )),

                          // Language
                          getExpansionPanel(
                            items[1],
                            ListTile(
                              title: ListView.builder(
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        side: const BorderSide(color: MyColors.purple, width: 1),
                                        backgroundColor: Colors.white),
                                    onPressed: () async {
                                      String lang = Languages().fos[index];
                                      user.User().language = lang;
                                      await Database().updateDoc(
                                          collection: 'Users',
                                          docId: user.User().id,
                                          key: 'language',
                                          value: lang);
                                      Get.offNamedUntil(
                                          MyStrings.routeMainFrame, ModalRoute.withName(MyStrings.routeLogo));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                      child: Text(language[index], style: const TextStyle(color: MyColors.purple)),
                                    ),
                                  );
                                },
                                itemCount: language.length,
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
                                          child: MyWidget().getTextFieldWidget(
                                              hint: MyStrings.feedbackHint,
                                              controller: TextEditingController(text: feedback),
                                              onChanged: (text) {
                                                feedback = text;
                                              }),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        MyWidget().getRoundBtnWidget(
                                          text: MyStrings.send,
                                          verticalPadding: 8,
                                          horizontalPadding: 3,
                                          textSize: 15,
                                          f: () async {
                                            try {
                                              if (feedback.isNotEmpty) {
                                                fb.Feedback userFeedback = fb.Feedback();
                                                userFeedback.userId = userId;
                                                userFeedback.email = userEmail;
                                                userFeedback.message = feedback;
                                                await Database()
                                                    .setDoc(collection: 'Feedbacks', doc: userFeedback);
                                                MyWidget().showSnackbar(title: MyStrings.thanksFeedback);
                                              }
                                            } catch (e) {
                                              if(e is PlatformException && e.code == "not_available") {
                                                MyWidget()
                                                    .showSnackbar(title: MyStrings.error, message: e.toString());
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
                                            text: MyStrings.yes,
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
                                              child: MyWidget().getRoundBtnWidget(
                                            text: MyStrings.cancel,
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
                                    MyWidget().getTextWidget(text: MyStrings.removeDetail, color: MyColors.red),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: MyWidget().getRoundBtnWidget(
                                            text: MyStrings.yes,
                                            textSize: 15,
                                            f: () {
                                              Get.dialog(
                                                AlertDialog(
                                                  title: MyWidget().getTextWidget(
                                                    text: MyStrings.areYouSure,
                                                    size: 20,
                                                    color: Colors.black,
                                                  ),
                                                  content: MyWidget().getTextWidget(
                                                    text: MyStrings.removeDetail2,
                                                    color: MyColors.red,
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: MyWidget().getTextWidget(text: MyStrings.yes),
                                                      onPressed: () {
                                                        User? user = auth.currentUser;
                                                        if (user != null) {
                                                          String providerId = '';
                                                          for (UserInfo providerData in user.providerData) {
                                                            providerId = providerData.providerId;
                                                          }
                                                          print('PROVIDER: $providerId');
                                                          switch (providerId) {
                                                            case 'password':
                                                              String password = '';
                                                              Get.back();
                                                              Get.dialog(AlertDialog(
                                                                title: MyWidget().getTextFieldWidget(
                                                                    hint: MyStrings.passwordAgain,
                                                                    onChanged: (value) {
                                                                      password = value;
                                                                    }),
                                                                actions: [
                                                                  TextButton(
                                                                    child: const Text(MyStrings.send),
                                                                    onPressed: () async {
                                                                      Get.back();
                                                                      try {
                                                                        await user.reauthenticateWithCredential(
                                                                          EmailAuthProvider.credential(
                                                                              email: user.email!,
                                                                              password: password),
                                                                        );
                                                                        await Database().deleteDoc(
                                                                            collection: 'Users',
                                                                            docId: auth.currentUser!.uid);
                                                                        await user.delete();
                                                                        print('User deleted');
                                                                      } catch (e) {
                                                                        showErrorSnackbar(e);
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
                                                      child: MyWidget().getTextWidget(text: MyStrings.cancel),
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
                                            text: MyStrings.cancel,
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
            MyWidget()
                .getRoundBtnWidget(text: MyStrings.edit, f: onClicked, verticalPadding: 8, horizontalPadding: 3)
          ],
        ),
      ],
    ),
  );
}

ExpansionPanel getExpansionPanel(MyPageItem item, Widget body) {
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
