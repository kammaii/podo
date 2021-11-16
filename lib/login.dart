import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:podo/my_colors.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  // Future<String?> _loginUser(LoginData data) {
  //   return Future.delayed(loginTime).then((_) {
  //     if (!mockUsers.containsKey(data.name)) {
  //       return 'User not exists';
  //     }
  //     if (mockUsers[data.name] != data.password) {
  //       return 'Password does not match';
  //     }
  //     return null;
  //   });
  // }

  Future<String?> _Login(LoginData data) {
    return Future.delayed(loginTime).then((_) {
      return 'Login Succeed';
    });
  }

  Future<String?> _Signup(LoginData data) {
    return Future.delayed(loginTime).then((_) {
      return 'Signup Succeed';
    });
  }

  Future<String?> _Recover(String data) {
    return Future.delayed(loginTime).then((_) {
      return 'Recover Succeed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlutterLogin(
        logo: 'assets/images/logo.png',
        title: 'Welcome to podo',
        theme: LoginTheme(
          primaryColor: MyColors.purple,
          pageColorLight: MyColors.green,
          accentColor: MyColors.purple,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold
          )
        ),
        loginProviders: <LoginProvider>[
          LoginProvider(
            icon: FontAwesomeIcons.google,
            callback: () async {
              print('start google sign in');
              return null;
            },
          ),
          LoginProvider(
            icon: FontAwesomeIcons.apple,
            callback: () async {
              print('start apple sign in');
              return null;
            },
          )
        ],
        onSignup: (signupData) {
          print('signupData');
          return _Signup(signupData);
        },
        onLogin: (loginData) {
          String email = loginData.name;
          String password = loginData.password;
          print(email);
          print(password);
          return _Login(loginData);
        },
        onRecoverPassword: (name) {
          print('recover password');
          return _Recover(name);
        },
        onSubmitAnimationCompleted: () {
          //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainFrame()));
        },
      ),
    );
  }
}
