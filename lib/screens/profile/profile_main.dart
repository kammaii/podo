import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo/common/database.dart';
import 'package:podo/common/my_date_format.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/screens/profile/feedback.dart' as fb;
import 'package:podo/values/my_colors.dart';
import 'package:podo/values/my_strings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class ProfileItem {
  late IconData icon;
  late String title;
  bool isExpanded = false;

  ProfileItem(this.icon, this.title);
}

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<ProfileItem> items = [
    ProfileItem(Icons.account_circle_rounded, MyStrings.editProfile),
    ProfileItem(Icons.feedback_outlined, MyStrings.feedback),
    ProfileItem(Icons.logout_rounded, MyStrings.logOut),
    ProfileItem(Icons.remove_circle_outline_rounded, MyStrings.removeAccount),
  ];
  List<String> userTier = ['New', 'Basic', 'Premium'];
  FirebaseAuth auth = FirebaseAuth.instance;
  String signupDate = '';
  String userId = '';
  String userEmail = '';
  String userName = '';
  User? currentUser;
  String feedback = '';

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

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
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
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyWidget().getTextWidget(
                        text: MyStrings.profile,
                        size: 20,
                        color: MyColors.purple,
                        isBold: true,
                      ),
                      //todo: status 값 가져오기
                      // MyWidget().getTextWidget(
                      //   text: userTier[user.User().status],
                      //   color: MyColors.grey,
                      // ),
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
                                                MyWidget().showSnackbar(title: MyStrings.profileChanged);
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
                                            text: MyStrings.yes,
                                            textSize: 15,
                                            f: () async {
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
                              items[3],
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
    for (ProfileItem item in items) {
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
