import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personalized_speech_interpreter/main.dart';
import 'package:personalized_speech_interpreter/prefs/ServerInfo.dart';
import 'package:personalized_speech_interpreter/soundUtils/BasicRecorder.dart';
import 'package:personalized_speech_interpreter/tcpClients/BasicTestClient.dart';
import 'package:personalized_speech_interpreter/utils/ToastGenerator.dart';

import 'package:personalized_speech_interpreter/tcpClients/FileTransferTestClient.dart';
import 'package:personalized_speech_interpreter/file/FileLoader.dart';

class TestPage extends StatefulWidget {
  @override
  State createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with WidgetsBindingObserver {
  final BasicRecorder _br = BasicRecorder();

  bool _isResetBtnClicked = false;

  String _state = "Unconnected";
  bool _isSending = false;
  bool _isSendBtnClicked = false;

  late FileTransferTestClient _client;

  TextEditingController? _servIPAddrController;
  TextEditingController? _servPortController;

  StreamSubscription? _mRecordingDataSubscription;

  int _typ = 1;

  // 파일 로드, 삭제 위한 객체
  final _fl = FileLoader();

  final String FIN_CODE = "Transfer Finished";

  // 실행 시간 측정 위한 객체
  late Stopwatch stopwatch;
  String _elapsedTimeText = "파일을 선택 후 전송해주세요.";
  String _returnedValue = "반환된 결과가 없습니다.";

  late ServerInfo _serv;

  bool _isSocketExists = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _client = FileTransferTestClient();
    _initializer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _startCon();
        Timer(const Duration(seconds: 1), () {
          setState(() {
            _isSocketExists = BasicTestClient.clntSocket != null;
          });
        });
        break;
      case AppLifecycleState.inactive:
        _stopCon();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          await Navigator.pushNamedAndRemoveUntil(
              context, MAIN_PAGE, (route) => false);
          ;
          return true;
        },
        child: Scaffold(
            body: Container(
                margin: const EdgeInsets.fromLTRB(0, 26, 0, 0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xffffffff), Color(0xfff2f2f2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
                child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 48),
                          SizedBox(
                              width: 326,
                              height: 40,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      if (FocusManager.instance.primaryFocus!
                                          is FocusScopeNode) {
                                        await Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            MAIN_PAGE,
                                            (route) => false);
                                        ;
                                      } else {
                                        // 키보드에 포커스가 있는 경우
                                        // 키보드 내리기
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      }
                                    },
                                    child: Image.asset(
                                        "assets/images/training_btn_back.png"),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    '관리자 페이지',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 28,
                                      color: Color(0xff191919),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    softWrap: false,
                                  ),
                                  const Spacer(),
                                  if (!_isSocketExists)
                                    Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 0, 16, 0),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          child: Image.asset(
                                              "assets/images/main_icon_sync_dis.png"),
                                        )),
                                ],
                              )),
                          const SizedBox(height: 32),
                          const SizedBox(
                            width: 296,
                            height: 21,
                            child: Text(
                              '서버 IP주소',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                color: Color(0xff454545),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            width: 296,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                        "assets/images/test_iv_input_background.png"))),
                            child: TextFormField(
                              decoration: const InputDecoration.collapsed(
                                hintText: '서버 IP주소를 입력하세요.',
                                hintStyle: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              controller: _servIPAddrController,
                              style: const TextStyle(
                                color: Color(0xff191919),
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(
                            width: 296,
                            height: 21,
                            child: Text(
                              '포트번호',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                color: Color(0xff454545),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            width: 296,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                        "assets/images/test_iv_input_background.png"))),
                            child: TextFormField(
                              decoration: const InputDecoration.collapsed(
                                hintText: '포트번호를 입력하세요.',
                                hintStyle: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              controller: _servPortController,
                              style: const TextStyle(
                                color: Color(0xff191919),
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 316,
                            height: 52,
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isResetBtnClicked = !_isResetBtnClicked;
                                });
                                _resetServAddrWithInput();
                              },
                              onTapDown: (_) => setState(() {
                                _isResetBtnClicked = !_isResetBtnClicked;
                              }),
                              onTapCancel: () => setState(() {
                                _isResetBtnClicked = !_isResetBtnClicked;
                              }),
                              child: Stack(
                                children: [
                                  _isResetBtnClicked
                                      ? Image.asset(
                                          "assets/images/test_btn_reset_clicked.png",
                                          gaplessPlayback: true)
                                      : Image.asset(
                                          "assets/images/test_btn_reset.png",
                                          gaplessPlayback: true),
                                  Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          30, 16, 0, 0),
                                      child: Text(
                                        "주소 설정",
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 14,
                                          color: _isResetBtnClicked
                                              ? const Color(0xffaaaaaa)
                                              : const Color(0xff191919),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ))
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 314,
                            height: 156,
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
                                                : Image.asset(
                                                    "assets/images/test_iv_box.png",
                                                    gaplessPlayback: true)),
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              14, 0, 0, 0),
                                          child: Text(
                                            'type1: wav파일 전송',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontSize: 16,
                                              color: (_typ == 1)
                                                  ? const Color(0xff191919)
                                                  : const Color(0xff676767),
                                              fontWeight: (_typ == 1)
                                                  ? FontWeight.w600
                                                  : null,
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
                                                : Image.asset(
                                                    "assets/images/test_iv_box.png",
                                                    gaplessPlayback: true)),
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              14, 0, 0, 0),
                                          child: Text(
                                            'type2: pcm파일 실시간 전송',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontSize: 16,
                                              color: (_typ == 2)
                                                  ? const Color(0xff191919)
                                                  : const Color(0xff676767),
                                              fontWeight: (_typ == 2)
                                                  ? FontWeight.w600
                                                  : null,
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
                                                : Image.asset(
                                                    "assets/images/test_iv_box.png",
                                                    gaplessPlayback: true)),
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              14, 0, 0, 0),
                                          child: Text(
                                            'type3: 식별정보(이름) 전송',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontSize: 16,
                                              color: (_typ == 3)
                                                  ? const Color(0xff191919)
                                                  : const Color(0xff676767),
                                              fontWeight: (_typ == 3)
                                                  ? FontWeight.w600
                                                  : null,
                                            ),
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              // 리스트 그림자
                              Container(
                                  width: 316,
                                  height: 294,
                                  child: Image.asset(
                                      "assets/images/test_iv_list_background_shadow.png")),
                              // 리스트
                              Container(
                                  margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                                  width: 296,
                                  height: 278,
                                  child: Image.asset(
                                      "assets/images/test_iv_list_background.png")),
                              Container(
                                  margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                                  width: 296,
                                  height: 278,
                                  child: MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: ListView.builder(
                                        // glow 제거
                                        physics: const BouncingScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: _fl.fileList.length,
                                        itemBuilder: (context, i) =>
                                            _setListItemBuilder(context, i),
                                      ))),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const SizedBox(
                            width: 296,
                            height: 21,
                            child: Text(
                              '실행 시간',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                color: Color(0xff454545),
                              ),
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // 실행시간 그림자
                              Container(
                                  width: 316,
                                  height: 66,
                                  child: Image.asset(
                                      "assets/images/test_iv_result_shadow.png")),
                              // 실행시간
                              Container(
                                  margin: const EdgeInsets.fromLTRB(0, 0, 1, 3),
                                  width: 296,
                                  height: 50,
                                  child: Image.asset(
                                      "assets/images/test_iv_result.png")),
                              Container(
                                width: 296,
                                height: 22,
                                margin: const EdgeInsets.fromLTRB(0, 1, 1, 5),
                                alignment: Alignment.center,
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
                            ],
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(
                            width: 296,
                            height: 21,
                            child: Text(
                              '반환 결과',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                color: Color(0xff454545),
                              ),
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // 실행시간 그림자
                              Container(
                                  width: 316,
                                  height: 66,
                                  child: Image.asset(
                                      "assets/images/test_iv_result_shadow.png")),
                              // 실행시간
                              Container(
                                  margin: const EdgeInsets.fromLTRB(0, 0, 1, 3),
                                  width: 296,
                                  height: 50,
                                  child: Image.asset(
                                      "assets/images/test_iv_result.png")),
                              Container(
                                width: 296,
                                height: 22,
                                margin: const EdgeInsets.fromLTRB(0, 1, 1, 5),
                                alignment: Alignment.center,
                                child: Text(
                                  textAlign: TextAlign.center,
                                  _returnedValue,
                                  style: const TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 16,
                                    color: Color(0xff000000),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  softWrap: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 332,
                                height: 66,
                                child: _typ != 2
                                    ? GestureDetector(
                                        onTapDown: _isSending
                                            ? null
                                            : (_) => setState(() {
                                                  _isSendBtnClicked =
                                                      !_isSendBtnClicked;
                                                }),
                                        onTapCancel: _isSending
                                            ? null
                                            : () => setState(() {
                                                  _isSendBtnClicked =
                                                      !_isSendBtnClicked;
                                                }),
                                        onTap: _isSending
                                            ? null
                                            : () => _startSend(),
                                        child: _isSendBtnClicked
                                            ? Image.asset(
                                                "assets/images/test_btn_send_clicked.png",
                                                gaplessPlayback: true,
                                              )
                                            : Image.asset(
                                                "assets/images/test_btn_send.png",
                                                gaplessPlayback: true,
                                              ),
                                      )
                                    : GestureDetector(
                                        onTapDown: (_) => setState(() {
                                          _isSendBtnClicked =
                                              !_isSendBtnClicked;
                                        }),
                                        onTapCancel: () => setState(() {
                                          _isSendBtnClicked =
                                              !_isSendBtnClicked;
                                        }),
                                        onTap: _isSending
                                            ? () => _stopRealTimeSend()
                                            : () => _startRealTimeSend(),
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
                              Container(
                                width: 300,
                                height: 22,
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                alignment: Alignment.center,
                                child: _typ != 2
                                    ? GestureDetector(
                                        onTapDown: _isSending
                                            ? null
                                            : (_) => setState(() {
                                                  _isSendBtnClicked =
                                                      !_isSendBtnClicked;
                                                }),
                                        onTapCancel: _isSending
                                            ? null
                                            : () => setState(() {
                                                  _isSendBtnClicked =
                                                      !_isSendBtnClicked;
                                                }),
                                        onTap: _isSending
                                            ? null
                                            : () => _startSend(),
                                        child: Text(
                                          _typ == 1
                                              ? '선택한 파일 전송'
                                              : '식별정보(이름) 전송',
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
                                      )
                                    : GestureDetector(
                                        onTapDown: (_) => setState(() {
                                          _isSendBtnClicked =
                                              !_isSendBtnClicked;
                                        }),
                                        onTapCancel: () => setState(() {
                                          _isSendBtnClicked =
                                              !_isSendBtnClicked;
                                        }),
                                        onTap: _isSending
                                            ? () => _stopRealTimeSend()
                                            : () => _startRealTimeSend(),
                                        child: Text(
                                          _isSending
                                              ? '실시간 전송 중단'
                                              : '실시간 전송 시작',
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
                            ],
                          ),
                          const SizedBox(height: 12),
                        ])))));
  }

  void _initializer() async {
    await _br.init();
    await _setServ();

    // 무조건 재설정
    _resetServAddr();
    _isSocketExists = BasicTestClient.clntSocket != null;

    // 내부저장소 경로 로드
    var docsDir = await getApplicationDocumentsDirectory();
    _fl.storagePath = '${docsDir.path}/recorded_files/거실 불 켜';
    setState(() {
      // 파일 리스트 초기화
      try {
        _fl.fileList = _fl.loadFiles();
      } on FileSystemException {
        print("Not initialized");
      }
    });
    if (_fl.fileList.isNotEmpty) {
      _fl.selectedFile = _fl.fileList[0];
    }

    _servIPAddrController = TextEditingController(text: _serv.servIPAddr);
    _servPortController = TextEditingController(text: _serv.servPort);

    await _br.setRecordingSession();
  }

  _setServ() async {
    _serv = ServerInfo();
    await _serv.setPrefs();
    _serv.loadServerInfo();
  }

  Future<void> _startSend() async {
    setState(() {
      _isSending = true;
    });

    await _sendData();

    setState(() {
      _isSending = false;
      _isSendBtnClicked = false;
    });
  }

  Future<void> _startRealTimeSend() async {
    setState(() {
      _isSending = true;
      _isSendBtnClicked = false;
      _elapsedTimeText = "실시간 녹음 및 전송 중입니다.";
    });
    stopwatch = Stopwatch()..start();

    _client.setServAddr(
        _servIPAddrController!.text, int.parse(_servPortController!.text));

    // 다른 타입의 sendFile 부분
    var start = Uint8List.fromList(utf8.encode("["));
    var typ = Uint8List.fromList([_typ]);
    var msgSize = Uint8List.fromList([7]);
    var ext = Uint8List.fromList(utf8.encode("pcm"));

    var header = start + typ + msgSize + ext;

    BasicTestClient.clntSocket!.add(header);

    // 실시간 전송 - 보류
    var recordingDataController = StreamController<Food>();
    _mRecordingDataSubscription =
        recordingDataController.stream.listen((buffer) {
      if (buffer is FoodData) {
        BasicTestClient.clntSocket!.add(buffer.data!);
      }
    });

    _br.recordingSession.openAudioSession();
    // 녹음 시작
    await _br.recordingSession.startRecorder(
      toStream: recordingDataController.sink,
      codec: Codec.pcm16,
    );
  }

  Future<void> _stopRealTimeSend() async {
    _br.recordingSession.stopRecorder();

    if (_mRecordingDataSubscription != null) {
      await _mRecordingDataSubscription!.cancel();
      _mRecordingDataSubscription = null;
    }

    var end = Uint8List.fromList(utf8.encode("]]")); // 임시 지정
    BasicTestClient.clntSocket!.add(end);

    await _stopCon();

    setState(() {
      _isSending = false;
      _isSendBtnClicked = false;
      _elapsedTimeText = "실시간 전송이 중단되었습니다.";
    });
  }

  Future<bool> _startCon() async {
    try {
      await _client.sendRequest();
    } on SocketException {
      setState(() {
        BasicTestClient.clntSocket = null;
        _isSocketExists = BasicTestClient.clntSocket != null;

        _elapsedTimeText = "서버 오류";
        _isSending = false;
        _isSendBtnClicked = false;
      });
      print("Connection refused");

      return false;
    } on Exception {
      print("Unexpected exception");

      return false;
    }
    setState(() {
      _state = "Connected";
    });
    if (BasicTestClient.clntSocket != null) {
      BasicTestClient.clntSocket!.listen((List<int> event) {
        setState(() {
          _state = utf8.decode(event);
          if (_typ != 2) {
            print("time elapsed: ${stopwatch.elapsed}");
            _elapsedTimeText = "${stopwatch.elapsed}";
          }
          _returnedValue = _state;
        });
      });
    }

    _isSocketExists = BasicTestClient.clntSocket != null;

    return true;
  }

  Future<void> _sendData() async {
    try {
      stopwatch = Stopwatch()..start();

      switch (_typ) {
        case 3:
          _client.sendID(_typ);
          break;
        default:
          Uint8List data =
              await _fl.readFile("${_fl.storagePath}/${_fl.selectedFile}");
          _client.sendFile(_typ, data);
          break;
      }
    } on FileSystemException {
      setState(() {
        _elapsedTimeText = "파일 선택 오류";
      });
      print("File not exists: ${_fl.selectedFile}");
    }

    if (BasicTestClient.clntSocket == null) {
      ToastGenerator.displayRegularMsg("연결에 실패했습니다.");
      print("Connection failed");
    }
  }

  Future<void> _stopCon() async {
    _client.stopClnt();
    setState(() {
      _state = "Disconnected";
    });
  }

  _resetServAddr() async {
    if (BasicTestClient.clntSocket != null) {
      await _stopCon();
    }
    bool chk = await _startCon();
  }

  _resetServAddrWithInput() async {
    _client.setServAddr(
        _servIPAddrController!.text, int.parse(_servPortController!.text));
    _serv.setServerInfo(_servIPAddrController!.text, _servPortController!.text);

    if (BasicTestClient.clntSocket != null) {
      await _stopCon();
    }
    bool chk = await _startCon();
    ToastGenerator.displayRegularMsg(chk ? "연결이 다시 설정되었습니다." : "연결에 실패했습니다.");
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
