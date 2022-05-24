import 'package:flutter/material.dart';
import 'package:podo/common_widgets/my_widget.dart';
import 'package:podo/values/my_colors.dart';

class TextFieldItem {
  late String hint;
  late bool hasAddBtn;
  late bool hasRemoveBtn;
  VoidCallback? addFunction;
  VoidCallback? removeFunction;

  TextFieldItem(this.hint, this.hasAddBtn, this.hasRemoveBtn);

  void setAddFunction(VoidCallback f) {
    addFunction = f;
  }

  void setRemoveFunction(VoidCallback f) {
    removeFunction = f;
  }

  Widget getWidget() {
    return Column(
      children: [
        const Align(alignment: Alignment.topRight, child: Text('0/30')),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(child: MyWidget().getTextFieldWidget(hint, 15)),
              const SizedBox(width: 10),
              hasRemoveBtn
                ? IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: MyColors.purple,
                  ),
                  onPressed: removeFunction
                )
                : const SizedBox.shrink(),
            ],
          ),
        ),
        hasAddBtn
          ? IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: MyColors.purple,
            ),
            onPressed: addFunction,
          )
          : const SizedBox.shrink(),
      ],
    );
  }
}
