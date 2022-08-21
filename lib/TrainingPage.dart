import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TrainingPage extends StatefulWidget {
  @override
  State createState() =>_TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  bool _isSending = false;
  bool _isSendBtnClicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: Stack(
        children: <Widget>[
          Pinned.fromPins(
            Pin(start: 22.0, end: 22.0),
            Pin(size: 400.0, middle: 0.425),
            child: Stack(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-0.807, -1.0),
                          end: Alignment(0.168, 1.0),
                          colors: [
                            const Color(0xe5dbd7d7),
                            const Color(0xe5d6d5d5)
                          ],
                          stops: [0.0, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: EdgeInsets.all(8.0),
                    ),
                    Container(
                      decoration: BoxDecoration(),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-0.807, -1.0),
                      end: Alignment(0.168, 1.0),
                      colors: [
                        const Color(0xfffcfcfc),
                        const Color(0xfff6f6f6)
                      ],
                      stops: [0.0, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  margin: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 10.0),
                ),
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(size: 296.0, middle: 0.5),
            Pin(size: 40.0, start: 64.0),
            child: const Text(
              '단어 학습',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 28,
                color: Color(0xff191919),
                fontWeight: FontWeight.w600,
              ),
              softWrap: false,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 332.0, middle: 0.5),
            Pin(size: 66.0, end: 12.0),
            child: GestureDetector(
              onTapDown: _isSending
                  ? null
                  : (_) => setState(() {
                _isSendBtnClicked = !_isSendBtnClicked;
              }),
              onTapCancel: _isSending
                  ? null
                  : () => setState(() {
                _isSendBtnClicked = !_isSendBtnClicked;
              }),
              onTap: _isSending ? null : () => _startSend(),
              child: _isSendBtnClicked
                  ? Image.asset(
                "assets/images/test_btn_send_clicked.png",
                gaplessPlayback: true,
              )
                  : Image.asset(
                "assets/images/test_btn_send.png",
                gaplessPlayback: true,
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(size: 142.0, middle: 0.5),
            Pin(size: 21.0, end: 35.0),
            child: GestureDetector(
              onTapDown: _isSending
                  ? null
                  : (_) => setState(() {
                _isSendBtnClicked = !_isSendBtnClicked;
              }),
              onTapCancel: _isSending
                  ? null
                  : () => setState(() {
                _isSendBtnClicked = !_isSendBtnClicked;
              }),
              onTap: _isSending ? null : () => _startSend(),
              child: Text(
                '입력한 음성으로 학습',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  color: _isSendBtnClicked
                      ? const Color(0xfffecdc8)
                      : const Color(0xfffefefe),
                  fontWeight: FontWeight.w600,
                ),
                softWrap: false,
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(start: 32.0, end: 32.0),
            Pin(size: 40.0, start: 114.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xfffcfcfc),
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(size: 9.0, end: 54.0),
            Pin(size: 6.0, start: 132.0),
            child: SvgPicture.string(
              _svg_wl75g,
              allowDrawingOutsideViewBox: true,
              fit: BoxFit.fill,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 168.0, end: 40.0),
            Pin(size: 60.0, middle: 0.7162),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.807, -1.0),
                  end: Alignment(0.168, 1.0),
                  colors: [const Color(0xfffcfcfc), const Color(0xfff6f6f6)],
                  stops: [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x29000000),
                    offset: Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(size: 42.0, end: 49.0),
            Pin(size: 42.0, middle: 0.7111),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.0, -1.0),
                  end: Alignment(0.0, 1.0),
                  colors: [const Color(0xffaaaaaa), const Color(0xff777777)],
                  stops: [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x29000000),
                    offset: Offset(2, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment(0.352, 0.422),
            child: Container(
              width: 42.0,
              height: 42.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.0, -1.0),
                  end: Alignment(0.0, 1.0),
                  colors: [const Color(0xffaaaaaa), const Color(0xff777777)],
                  stops: [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x29000000),
                    offset: Offset(2, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment(0.013, 0.422),
            child: Container(
              width: 42.0,
              height: 42.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.0, -1.0),
                  end: Alignment(0.0, 1.0),
                  colors: [const Color(0xffef8d7c), const Color(0xffd16b69)],
                  stops: [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x29000000),
                    offset: Offset(2, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment(0.322, 0.406),
            child: Container(
              width: 12.0,
              height: 12.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.0),
                border: Border.all(width: 1.0, color: const Color(0xffffffff)),
              ),
            ),
          ),
          Align(
            alignment: Alignment(0.012, 0.411),
            child: SizedBox(
              width: 14.0,
              height: 22.0,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 6.0,
                      height: 14.0,
                      child: SvgPicture.string(
                        _svg_jxk0e,
                        allowDrawingOutsideViewBox: true,
                      ),
                    ),
                  ),
                  Pinned.fromPins(
                    Pin(start: 0.0, end: 0.0),
                    Pin(size: 9.1, middle: 0.6923),
                    child: SvgPicture.string(
                      _svg_bp16xk,
                      allowDrawingOutsideViewBox: true,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Align(
                    alignment: Alignment(0.102, 1.0),
                    child: SizedBox(
                      width: 1.0,
                      height: 4.0,
                      child: SvgPicture.string(
                        _svg_ypiz1w,
                        allowDrawingOutsideViewBox: true,
                      ),
                    ),
                  ),
                  Pinned.fromPins(
                    Pin(start: 2.9, end: 3.0),
                    Pin(size: 1.0, end: -1.0),
                    child: SvgPicture.string(
                      _svg_ioof8t,
                      allowDrawingOutsideViewBox: true,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startSend() {

  }
}

const String _svg_wl75g =
    '<svg viewBox="297.0 132.0 9.0 6.0" ><path transform="matrix(-1.0, 0.0, 0.0, -1.0, 306.0, 138.0)" d="M 4.5 0 L 9 6 L 0 6 Z" fill="#676767" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_jxk0e =
    '<svg viewBox="9.1 1.0 6.1 14.2" ><path transform="translate(0.06, 0.0)" d="M 12.04714012145996 0.9999998807907104 C 10.36425018310547 0.9999998807907104 8.999998092651367 2.364252090454102 8.999998092651367 4.047141551971436 L 8.999998092651367 12.17285060882568 C 8.999998092651367 13.85574150085449 10.36425018310547 15.21999263763428 12.04714012145996 15.21999263763428 C 13.73003005981445 15.21999263763428 15.09428024291992 13.85574150085449 15.09428024291992 12.17285060882568 L 15.09428024291992 4.047141075134277 C 15.09428024291992 2.364251613616943 13.73003005981445 0.9999998807907104 12.04714012145996 0.9999998807907104 Z" fill="none" stroke="#fcfcfc" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" /></svg>';
const String _svg_bp16xk =
    '<svg viewBox="5.0 10.1 14.2 9.1" ><path transform="translate(0.0, 0.14)" d="M 19.21999359130859 9.999999046325684 L 19.21999359130859 12.03142642974854 C 19.21999359130859 15.95816802978516 16.03673934936523 19.14142227172852 12.10999774932861 19.14142227172852 C 8.183254241943359 19.14142227172852 5.000000476837158 15.95816802978516 5 12.03142738342285 L 4.999999523162842 9.999999046325684" fill="none" stroke="#fcfcfc" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" /></svg>';
const String _svg_ypiz1w =
    '<svg viewBox="12.3 19.5 1.0 3.9" ><path transform="translate(12.29, 19.46)" d="M 0 0 L 0 3.88620924949646" fill="none" stroke="#fcfcfc" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" /></svg>';
const String _svg_ioof8t =
    '<svg viewBox="7.9 23.3 8.3 1.0" ><path transform="translate(7.91, 23.35)" d="M 0 0 L 8.258194923400879 0" fill="none" stroke="#fcfcfc" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" /></svg>';
