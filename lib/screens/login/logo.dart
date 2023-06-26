import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class Logo extends StatelessWidget {
  Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String version = '';
    PackageInfo.fromPlatform().then((value) {
      version = value.version;
    });

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(top: 20.0, right: 20.0, child: Text('version : $version')),
              Center(child: Image.asset('assets/images/logo.png')),
              Positioned(
                bottom: 100.0,
                child: Row(
                  children: const [
                    SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.0,
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Text('Loading...')
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
