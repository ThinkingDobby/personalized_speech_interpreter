import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';

class main_page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f6), // 임시
      body: Stack(
        children: <Widget>[
          Pinned.fromPins(
            Pin(size: 157.0, middle: 0.53),
            Pin(size: 157.0, end: 32.0),
            child: Image.asset("assets/images/main_btn_record_norm.png"),
          ),
          Pinned.fromPins(
            Pin(start: 32.0, end: 32.0),
            Pin(size: 180.0, middle: 0.3645),
            child: Image.asset("assets/images/main_iv_signal.png")
          ),
          Pinned.fromPins(
              Pin(start: 22, end: 22),
              Pin(size: 112.0, middle: 0.633),
              child: Image.asset("assets/images/main_iv_result_shadow.png")
          ),
          Pinned.fromPins(
            Pin(start: 32.0, end: 32.0),
            Pin(size: 96.0, middle: 0.6222),
            child: Image.asset("assets/images/main_iv_result.png")
          ),
          Align(
            alignment: Alignment(0.0, -0.656),
            child: SizedBox(
              width: 126.0,
              height: 68.0,
              child: Text(
                '00:00',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 52,
                  color: const Color(0xff676767),
                  fontWeight: FontWeight.w300,
                ),
                softWrap: false,
              ),
            ),
          ),
          Align(
            alignment: Alignment(0.004, 0.222),
            child: SizedBox(
              width: 87.0,
              height: 26.0,
              child: Text(
                '거실 불 켜',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  color: const Color(0xff000000),
                ),
                softWrap: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}