import 'dart:ui';

import 'package:fluttertoast/fluttertoast.dart';

class ToastGenerator {
  static void displayRegularMsg(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color(0xff999999),
        textColor: const Color(0xfffefefe),
        fontSize: 16.0);
  }
}