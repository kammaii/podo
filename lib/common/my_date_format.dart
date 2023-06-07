import 'package:intl/intl.dart';

class MyDateFormat {
  String getDateFormat(DateTime time) {
    return DateFormat('yyyy.MM.dd').format(time);
  }
}