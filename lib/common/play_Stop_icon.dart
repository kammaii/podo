import 'package:flutter/material.dart';
import 'package:podo/values/my_colors.dart';

class PlayStopIcon {

  TickerProvider provider;
  late final AnimationController controller;
  late final AnimatedIcon icon;
  late final double size;

  PlayStopIcon(this.provider, {this.size = 30}) {
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: provider,
    );
    icon = AnimatedIcon(
      icon: AnimatedIcons.play_pause,
      progress: controller,
      size: size,
      color: MyColors.purple,
    );
  }

  void clickIcon({required bool isForward}) {
    if (isForward) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }
}