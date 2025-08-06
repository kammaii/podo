import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:podo/common/my_widget.dart';
import 'package:podo/common/responsive_size.dart';
import 'package:podo/screens/login/fcm_controller.dart';
import 'package:podo/screens/login/auth_controller.dart';
import 'package:podo/screens/login/deeplinks.dart';

class Logo extends StatefulWidget {
  Logo({Key? key}) : super(key: key);

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> {

  @override
  void initState() {
    super.initState();
    Get.isRegistered<FcmController>() ? null : Get.put(FcmController(), permanent: true);
    Get.isRegistered<AuthController>() ? null : Get.put(AuthController(), permanent: true);
    Get.isRegistered<DeepLinks>() ? null : Get.put(DeepLinks(), permanent: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.previousRoute.isNotEmpty) {
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveSize rs = ResponsiveSize(context);

    return Scaffold(
      body: Container(
        color: Theme.of(context).cardColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return Positioned(
                      top: rs.getSize(20),
                      right: rs.getSize(20),
                      child: MyWidget().getTextWidget(rs,
                          text: 'version : ${snapshot.data.version}',
                          color: Theme.of(context).secondaryHeaderColor));
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            Center(child: Image.asset('assets/images/logo.png')),
            Positioned(
              bottom: 100.0,
              child: Row(
                children: [
                  SizedBox(
                    height: rs.getSize(20),
                    width: rs.getSize(20),
                    child: CircularProgressIndicator(
                      strokeWidth: rs.getSize(1),
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  MyWidget().getTextWidget(rs, text: 'Loading...', color: Theme.of(context).secondaryHeaderColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
