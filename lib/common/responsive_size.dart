import 'package:flutter/cupertino.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';

class ResponsiveSize {

  BuildContext context;

  ResponsiveSize(this.context);

  double getSize(double size, {double bigger = 1}) {
    if(!ResponsiveBreakpoints.of(context).isMobile) {
      size = size * 1.5 * bigger;
    }
    return size;
  }
}