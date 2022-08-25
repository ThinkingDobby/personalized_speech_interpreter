import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:path_provider/path_provider.dart';

import 'package:personalized_speech_interpreter/tcpClients/FileTransferTestClient.dart';
import 'package:personalized_speech_interpreter/file/FileLoader.dart';

class TestPage extends StatefulWidget {
  @override
  State createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String _state = "Unconnected";
  bool _isSending = false;
  bool _isSendBtnClicked = false;

  late FileTransferTestClient _client;

  int _typ = 1;

  // 파일 로드, 삭제 위한 객체
  final _fl = FileLoader();

  final String FIN_CODE = "Transfer Finished";

  // 실행 시간 측정 위한 객체
  late Stopwatch stopwatch;
  String _elapsedTimeText = "파일을 선택 후 전송해주세요.";

  @override
  void initState() {
    super.initState();
    _client = FileTransferTestClient();
    _initializer();
  }

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
          Pinned.fromPins(
            Pin(size: 314, middle: 0.5),
            Pin(size: 156, start: 114),
            child: Column(
              children: <Widget>[
                GestureDetector(
                    onTapDown: (_typ == 1)
                        ? null
                        : (_) => setState(() {
                              _typ = 1;
                            }),
                    onTap: (_typ == 1)
                        ? null
                        : () => setState(() {
                              _typ = 1;
                            }),
                    child: Row(
                      children: [
                        Container(
                            width: 52,
                            height: 52,
                            child: (_typ == 1)
                                ? Image.asset(
                                    "assets/images/test_iv_box_clicked.png",
                                    gaplessPlayback: true,
                                  )
                                : Image.asset("assets/images/test_iv_box.png",
                                    gaplessPlayback: true)),
                        Container(
                          margin: const EdgeInsets.fromLTRB(14, 0, 0, 0),
                          child: Text(
                            'type1: 전송 - 파일에 저장',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              color: (_typ == 1)
                                  ? const Color(0xff191919)
                                  : const Color(0xff676767),
                              fontWeight: (_typ == 1) ? FontWeight.w600 : null,
                            ),
                            softWrap: false,
                          ),
                        ),
                      ],
                    )),
                GestureDetector(
                    onTapDown: (_typ == 2)
                        ? null
                        : (_) => setState(() {
                              _typ = 2;
                            }),
                    onTap: (_typ == 2)
                        ? null
                        : () => setState(() {
                              _typ = 2;
                            }),
                    child: Row(
                      children: [
                        Container(
                            width: 52,
                            height: 52,
                            child: (_typ == 2)
                                ? Image.asset(
                                    "assets/images/test_iv_box_clicked.png",
                                    gaplessPlayback: true,
                                  )
                                : Image.asset("assets/images/test_iv_box.png",
                                    gaplessPlayback: true)),
                        Container(
                          margin: const EdgeInsets.fromLTRB(14, 0, 0, 0),
                          child: Text(
                            'type2: 전송 - 메모리에만 저장',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              color: (_typ == 2)
                                  ? const Color(0xff191919)
                                  : const Color(0xff676767),
                              fontWeight: (_typ == 2) ? FontWeight.w600 : null,
                            ),
                            softWrap: false,
                          ),
                        ),
                      ],
                    )),
                GestureDetector(
                    onTapDown: (_typ == 3)
                        ? null
                        : (_) => setState(() {
                              _typ = 3;
                            }),
                    onTap: (_typ == 3)
                        ? null
                        : () => setState(() {
                              _typ = 3;
                            }),
                    child: Row(
                      children: [
                        Container(
                            width: 52,
                            height: 52,
                            child: (_typ == 3)
                                ? Image.asset(
                                    "assets/images/test_iv_box_clicked.png",
                                    gaplessPlayback: true,
                                  )
                                : Image.asset("assets/images/test_iv_box.png",
                                    gaplessPlayback: true)),
                        Container(
                          margin: const EdgeInsets.fromLTRB(14, 0, 0, 0),
                          child: Text(
                            'type3: ',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              color: (_typ == 3)
                                  ? const Color(0xff191919)
                                  : const Color(0xff676767),
                              fontWeight: (_typ == 3) ? FontWeight.w600 : null,
                            ),
                            softWrap: false,
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(size: 296.0, middle: 0.5),
            Pin(size: 40.0, start: 64.0),
            child: const Text(
              '관리자 페이지',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 28,
                color: Color(0xff191919),
                fontWeight: FontWeight.w600,
              ),
              softWrap: false,
            ),
          ),
          // 실행시간 그림자
          Pinned.fromPins(
              Pin(size: 316.0, middle: 0.5), Pin(size: 66.0, end: 77.0),
              child: Image.asset("assets/images/test_iv_result_shadow.png")),
          // 실행시간
          Pinned.fromPins(
              Pin(size: 296, middle: 0.5), Pin(size: 50.0, end: 88.0),
              child: Image.asset("assets/images/test_iv_result.png")),
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
            Pin(size: 114.0, middle: 0.5),
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
                '선택한 파일 전송',
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
            Pin(size: 296.0, middle: 0.5),
            Pin(size: 21.0, end: 144.0),
            child: const Text(
              '실행 시간',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                color: Color(0xff454545),
              ),
              softWrap: false,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 296.0, middle: 0.5),
            Pin(size: 21.0, end: 102.0),
            child: Text(
              textAlign: TextAlign.center,
              _elapsedTimeText,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                color: Color(0xff000000),
                fontWeight: FontWeight.w500,
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
          Pinned.fromPins(
            Pin(size: 296.0, middle: 0.5),
            Pin(size: 278.0, middle: 0.59),
            child: Expanded(
                flex: 1,
                child: ListView.builder(
                  // glow 제거
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: _fl.fileList.length,
                  itemBuilder: (context, i) => _setListItemBuilder(context, i),
                )),
          ),
        ],
      ),
    ));
  }

  void _initializer() async {
    // 내부저장소 경로 로드
    var docsDir = await getApplicationDocumentsDirectory();
    _fl.storagePath = '${docsDir.path}/recorded_files';
    setState(() {
      // 파일 리스트 초기화
      _fl.fileList = _fl.loadFiles();
    });
    if (_fl.fileList.isNotEmpty) {
      _fl.selectedFile = _fl.fileList[0];
    }
  }

  Future<void> _startSend() async {
    setState(() {
      _isSending = true;
    });

    await _startCon();
    await _sendData();
    await _stopCon();

    setState(() {
      _isSending = false;
      _isSendBtnClicked = false;
    });
  }

  Future<void> _startCon() async {
    try {
      await _client.sendRequest();
    } on SocketException {
      setState(() {
        _elapsedTimeText = "서버 오류";
      });
      print("Connection refused");
    }
    setState(() {
      _state = "Connected";
    });
    _client.clntSocket.listen((List<int> event) {
      setState(() {
        _state = utf8.decode(event);
        if (_state == FIN_CODE) {
          _client.clntSocket.done;
          print("time elapsed: ${stopwatch.elapsed}");
          _elapsedTimeText = "${stopwatch.elapsed}";
        }
      });
    });
  }

  Future<void> _sendData() async {
    try {
      Uint8List data =
          await _fl.readFile("${_fl.storagePath}/${_fl.selectedFile}");
      stopwatch = Stopwatch()..start();
      _client.sendFile(_typ, data);
    } on FileSystemException {
      setState(() {
        _elapsedTimeText = "파일 선택 오류";
      });
      print("File not exists: ${_fl.selectedFile}");
    }
  }

  Future<void> _stopCon() async {
    _client.stopClnt();
    setState(() {
      _state = "Disconnected";
    });
  }

  RadioListTile _setListItemBuilder(BuildContext context, int i) {
    return RadioListTile(
        title: Text(_fl.fileList[i]),
        value: _fl.fileList[i],
        groupValue: _fl.selectedFile,
        activeColor: const Color(0xffd55f52),
        controlAffinity: ListTileControlAffinity.trailing,
        onChanged: (val) {
          setState(() {
            _fl.selectedFile = _fl.fileList[i];
          });
        });
  }
}
