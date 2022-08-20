import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';

class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xffffffff), Color(0xfff2f2f2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: Stack(
        children: <Widget>[
          // 첫번째 체크박스
          Pinned.fromPins(
              Pin(size: 52.0, middle: 0.11), Pin(size: 52.0, start: 128.0),
              child: Image.asset("assets/images/test_iv_box_clicked.png")),
          // 두번째 체크박스
          Pinned.fromPins(
              Pin(size: 52.0, middle: 0.11), Pin(size: 52.0, start: 180.0),
              child: Image.asset("assets/images/test_iv_box.png")),
          // 세번째 체크박스
          Pinned.fromPins(
              Pin(size: 52.0, middle: 0.11), Pin(size: 52.0, start: 232.0),
              child: Image.asset("assets/images/test_iv_box.png")),
          Pinned.fromPins(
            Pin(size: 296.0, middle: 0.5),
            Pin(size: 40.0, start: 64.0),
            child: const Text(
              '관리자 페이지',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 32,
                color: Color(0xff191919),
                fontWeight: FontWeight.w600,
              ),
              softWrap: false,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 208.0, middle: 0.56),
            Pin(size: 22.0, start: 140.0),
            child: const Text(
              'type1: 전송 - 파일에 저장',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                color: Color(0xff191919),
                fontWeight: FontWeight.w600,
              ),
              softWrap: false,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 208.0, middle: 0.56),
            Pin(size: 22.0, start: 192.0),
            child: const Text(
              'type2: 전송 - 메모리에만 저장',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                color: Color(0xff676767),
              ),
              softWrap: false,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 208.0, middle: 0.56),
            Pin(size: 22.0, start: 244.0),
            child: const Text(
              'type3: FFT - 전송 - 파일에 저장',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                color: Color(0xff676767),
              ),
              softWrap: false,
            ),
          ),
          // 실행시간 그림자
          Pinned.fromPins(
              Pin(size: 316.0, middle: 0.5), Pin(size: 66.0, end: 108.0),
              child: Image.asset("assets/images/test_iv_result_shadow.png")),
          // 실행시간
          Pinned.fromPins(
              Pin(size: 296, middle: 0.5), Pin(size: 50.0, end: 119.0),
              child: Image.asset("assets/images/test_iv_result.png")),
          Pinned.fromPins(
              Pin(size: 316.0, middle: 0.5), Pin(size: 66.0, end: 24.0),
              child: Image.asset("assets/images/test_btn_send.png")),
          Pinned.fromPins(
            Pin(size: 296.0, middle: 0.5),
            Pin(size: 21.0, middle: 0.7734),
            child: const Text(
              '실행 시간',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                color: Color(0xff454545),
              ),
              softWrap: false,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 68.0, middle: 0.5),
            Pin(size: 21.0, end: 133.0),
            child: const Text(
              '0.032 초',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                color: Color(0xff000000),
                fontWeight: FontWeight.w500,
              ),
              softWrap: false,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 114.0, middle: 0.5),
            Pin(size: 21.0, end: 49.0),
            child: const Text(
              '선택한 파일 전송',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                color: Color(0xfffefefe),
                fontWeight: FontWeight.w600,
              ),
              softWrap: false,
            ),
          ),
          // 리스트 그림자
          Pinned.fromPins(
              Pin(size: 316.0, middle: 0.5), Pin(size: 294.0, middle: 0.5939),
              child: Image.asset(
                  "assets/images/test_iv_list_background_shadow.png")),
          // 리스트
          Pinned.fromPins(
              Pin(size: 296.0, middle: 0.5), Pin(size: 278.0, middle: 0.59),
              child: Image.asset("assets/images/test_iv_list_background.png")),
        ],
      ),
    ));
  }
}
