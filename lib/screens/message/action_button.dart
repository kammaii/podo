import 'package:flutter/material.dart';
import 'package:podo/values/my_colors.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;

  const ActionButton({Key? key, this.onPressed, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: MyColors.purple,
      elevation: 4.0,
      child: IconButton(
        color: Colors.white,
        icon: icon,
        onPressed: onPressed
      ),
    );
  }
}
