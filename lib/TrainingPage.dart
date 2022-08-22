import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';

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
            child: Image.asset("assets/images/training_iv_list_background.png")
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
          // 드롭다운
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
            Pin(size: 320.0, middle: 0.5),
            Pin(size: 98.0, middle: 0.734),
            child: Image.asset("assets/images/training_iv_control.png")
          ),
          Pinned.fromPins(
            Pin(size: 320.0, middle: 0.5),
            Pin(size: 98.0, middle: 0.734),
            child: Container(
              margin: const EdgeInsets.fromLTRB(139, 0, 0, 10),
              child: Row(
                children: <Widget> [
                  Container(
                    width: 49, height: 49,
                    child: Image.asset("assets/images/training_btn_record.png"),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    width: 49, height: 49,
                    child: Image.asset("assets/images/training_btn_stop.png"),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    width: 49, height: 49,
                    child: Image.asset("assets/images/training_btn_stop.png"),
                  ),
                ],
              )
            )
          )
        ],
      ),
    );
  }

  void _startSend() {
  }
}