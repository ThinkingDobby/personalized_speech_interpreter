import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: Stack(
        children: <Widget>[
          Pinned.fromPins(
            Pin(start: 31.0, end: 29.0),
            Pin(size: 50.0, end: 32.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.807, -1.0),
                  end: Alignment(0.168, 1.0),
                  colors: [const Color(0xe5dbd7d7), const Color(0xe5d6d5d5)],
                  stops: [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(size: 36.0, start: 34.0),
            Pin(size: 36.0, middle: 0.2461),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.807, -1.0),
                  end: Alignment(0.168, 1.0),
                  colors: [const Color(0xe5dbd7d7), const Color(0xe5d6d5d5)],
                  stops: [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(size: 36.0, start: 32.0),
            Pin(size: 36.0, middle: 0.2435),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(size: 36.0, start: 34.0),
            Pin(size: 36.0, middle: 0.3141),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.807, -1.0),
                  end: Alignment(0.168, 1.0),
                  colors: [const Color(0xe5dbd7d7), const Color(0xe5d6d5d5)],
                  stops: [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(size: 36.0, start: 32.0),
            Pin(size: 36.0, middle: 0.3115),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(size: 174.0, start: 32.0),
            Pin(size: 38.0, start: 64.0),
            child: Text(
              '관리자 페이지',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 32,
                color: const Color(0xff191919),
                fontWeight: FontWeight.w600,
              ),
              softWrap: false,
            ),
          ),
          Align(
            alignment: Alignment(-0.061, -0.631),
            child: SizedBox(
              width: 164.0,
              height: 19.0,
              child: Text(
                'type1: 전송 - 파일에 저장',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  color: const Color(0xff191919),
                  fontWeight: FontWeight.w600,
                ),
                softWrap: false,
              ),
            ),
          ),
          Align(
            alignment: Alignment(0.102, -0.498),
            child: SizedBox(
              width: 193.0,
              height: 19.0,
              child: Text(
                'type2: 전송 - 메모리에만 저장',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  color: const Color(0xff676767),
                ),
                softWrap: false,
              ),
            ),
          ),
          Align(
            alignment: Alignment(0.211, -0.365),
            child: SizedBox(
              width: 208.0,
              height: 19.0,
              child: Text(
                'type3: FFT - 전송 - 파일에 저장',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  color: const Color(0xff676767),
                ),
                softWrap: false,
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(start: 30.0, end: 30.0),
            Pin(size: 50.0, end: 116.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.807, -1.0),
                  end: Alignment(0.168, 1.0),
                  colors: [const Color(0xe5dbd7d7), const Color(0xe5d6d5d5)],
                  stops: [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(start: 31.0, end: 33.0),
            Pin(size: 50.0, end: 119.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.807, -1.0),
                  end: Alignment(0.168, 1.0),
                  colors: [const Color(0xfffcfcfc), const Color(0xfff6f6f6)],
                  stops: [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(start: 31.0, end: 33.0),
            Pin(size: 50.0, end: 34.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.807, -1.0),
                  end: Alignment(0.168, 1.0),
                  colors: [const Color(0xffdb8278), const Color(0xffe59288)],
                  stops: [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(size: 59.0, start: 30.0),
            Pin(size: 19.0, middle: 0.7734),
            child: Text(
              '실행 시간',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                color: const Color(0xff454545),
              ),
              softWrap: false,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 68.0, middle: 0.5),
            Pin(size: 21.0, end: 130.0),
            child: Text(
              '0.032 초',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                color: const Color(0xff000000),
                fontWeight: FontWeight.w500,
              ),
              softWrap: false,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 104.0, middle: 0.4805),
            Pin(size: 19.0, end: 49.0),
            child: Text(
              '선택한 파일 전송',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                color: const Color(0xfffefefe),
                fontWeight: FontWeight.w600,
              ),
              softWrap: false,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 36.0, start: 32.0),
            Pin(size: 36.0, middle: 0.1754),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(start: 30.0, end: 30.0),
            Pin(size: 278.0, middle: 0.5939),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.807, -1.0),
                  end: Alignment(0.168, 1.0),
                  colors: [const Color(0xe5dbd7d7), const Color(0xe5d6d5d5)],
                  stops: [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(start: 32.0, end: 32.0),
            Pin(size: 278.0, middle: 0.59),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.807, -1.0),
                  end: Alignment(0.168, 1.0),
                  colors: [const Color(0xfffcfcfc), const Color(0xfff6f6f6)],
                  stops: [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(size: 13.0, start: 44.0),
            Pin(size: 11.0, start: 147.0),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomLeft,
                  child: SizedBox(
                    width: 6.0,
                    height: 6.0,
                    child: SvgPicture.string(
                      _svg_bboilx,
                      allowDrawingOutsideViewBox: true,
                    ),
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 7.0, end: 0.0),
                  Pin(start: 0.0, end: 0.0),
                  child: SvgPicture.string(
                    _svg_ppw07r,
                    allowDrawingOutsideViewBox: true,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const String _svg_bboilx =
    '<svg viewBox="44.0 152.0 6.0 6.0" ><path transform="translate(44.0, 152.0)" d="M 0 0 L 6 6" fill="none" stroke="#db8278" stroke-width="2" stroke-miterlimit="4" stroke-linecap="round" /></svg>';
const String _svg_ppw07r =
    '<svg viewBox="50.0 147.0 7.0 11.0" ><path transform="translate(50.0, 147.0)" d="M 7 0 L 0 11" fill="none" stroke="#db8278" stroke-width="2" stroke-miterlimit="4" stroke-linecap="round" /></svg>';
