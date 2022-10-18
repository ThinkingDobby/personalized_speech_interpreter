import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personalized_speech_interpreter/prefs/ServerInfo.dart';
import 'package:personalized_speech_interpreter/prefs/UserInfo.dart';
import 'package:personalized_speech_interpreter/protocols/DecodingMessage.dart';
import 'package:personalized_speech_interpreter/soundUtils/BasicRecorder.dart';
import 'package:personalized_speech_interpreter/tcpClients/BasicTestClient.dart';
import 'package:personalized_speech_interpreter/tcpClients/FileTransferTestClient.dart';
import 'package:personalized_speech_interpreter/utils/ToastGenerator.dart';
import 'package:personalized_speech_interpreter/utils/checkAndRequestPermission.dart';
import 'package:sprintf/sprintf.dart';

import 'file/FileLoader.dart';
import 'main.dart';

class MainPage extends StatefulWidget {
  @override
  State createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final BasicRecorder _br = BasicRecorder();

  int _time = 0;
  String _timeText = "00:00";
  String _message = "";

  String _state = "Unconnected";
  final String FIN_CODE = "Transfer Finished";

  // 녹음 위한 파일 경로 (저장소 경로 + 파일명)
  late String _filePathForRecord;

  // late String _filePathForWaveVisualize;

  // 파일 로드, 삭제 위한 객체
  final _fl = FileLoader();

  late Timer _timer;

  late FileTransferTestClient _client;

  // 실행 시간 측정 위한 객체
  late Stopwatch stopwatch;

  late UserInfo _user;
  String _userName = '';

  late ServerInfo _serv;

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
        // 메인 페이지의 경우 복귀 시 주소 변경이 일어날 수 있음
        _setServAddr();
        _startCon();
        print("App Lifecycle State: resumed");
        break;
      case AppLifecycleState.inactive:
        _stopCon();
        print("App Lifecycle State: inactive");
        break;
      case AppLifecycleState.paused:
        print("App Lifecycle State: paused");
        break;
      case AppLifecycleState.detached:
        print("App Lifecycle State: detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _setUser();

    Widget _buildMainComponents() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      width: 52,
                      height: 32,
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Builder(
                        builder: (context) {
                          return InkWell(
                              onDoubleTap: () async {
                                if (!_br.isRecording) {
                                  await Navigator.pushNamedAndRemoveUntil(context, TEST_PAGE, (route) => false);
                                } else {
                                  ToastGenerator.displayRegularMsg(
                                      "음성 입력 중에는 이동이 불가능합니다.");
                                }
                              },
                              child: Image.asset("assets/images/icon.png"));
                        },
                      )),
                  const Spacer(),
                  if (BasicTestClient.clntSocket == null)
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                        child: Container(
                          width: 32,
                          height: 32,
                          child: Image.asset(
                              "assets/images/main_icon_sync_dis.png"),
                        )),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 16, 16, 0),
                    child: Container(
                      width: 50,
                      height: 50,
                      child: InkWell(
                          onTap: () async {
                            if (!_br.isRecording) {
                              await Navigator.pushNamedAndRemoveUntil(context, SENTENCES_PAGE, (route) => false);
                            } else {
                              ToastGenerator.displayRegularMsg(
                                  "음성 입력 중에는 이동이 불가능합니다.");
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                child: Image.asset(
                                    "assets/images/main_book_icon.png"),
                              ),
                              const Text(
                                "문장학습",
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  color: Color(0xff191919),
                                  fontWeight: FontWeight.w400,
                                ),
                                softWrap: false,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.fromLTRB(32, 0, 32, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 32,
                            color: Color(0xff191919),
                            fontWeight: FontWeight.w500,
                          ),
                          softWrap: false,
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          "님,",
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 28,
                            color: Color(0xff191919),
                            fontWeight: FontWeight.w400,
                          ),
                          softWrap: false,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "안녕하세요.",
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 34,
                        color: Color(0xff191919),
                        fontWeight: FontWeight.w400,
                      ),
                      softWrap: false,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "하단의 마이크 버튼을 터치 후, 번역할 문장을 말씀해주세요.",
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        color: Color(0xff676767),
                        fontWeight: FontWeight.w400,
                      ),
                      softWrap: true,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              )
            ],
          ),
          if (MediaQuery.of(context).size.height >= 670)
            const Spacer()
          else
            const SizedBox(height: 48),
          Container(
            alignment: Alignment.center,
            width: 296.0,
            height: 45.0,
            child: Text(
              _timeText,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 32,
                color: Color(0xff676767),
                fontWeight: FontWeight.w300,
              ),
              softWrap: false,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              SizedBox(
                  width: 296,
                  height: 110,
                  child: Image.asset("assets/images/main_iv_signal.png")),
              SizedBox(
                width: 296,
                height: 110,
                child: AudioWaveforms(
                  waveStyle: WaveStyle(
                    gradient: ui.Gradient.linear(
                      const Offset(70, 50),
                      Offset(MediaQuery.of(context).size.width / 2, 0),
                      [const Color(0xffdc8379), const Color(0xfff5b6ae)],
                    ),
                    showMiddleLine: false,
                    extendWaveform: true,
                  ),
                  enableGesture: false,
                  size: Size(MediaQuery.of(context).size.width, 110.0),
                  recorderController: _br.recorderController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                  width: 316,
                  height: 112,
                  child:
                      Image.asset("assets/images/main_iv_result_shadow.png")),
              Container(
                  margin: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                  width: 296,
                  height: 96,
                  child: Image.asset("assets/images/main_iv_result.png")),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                width: 296,
                height: 96,
                child: Text(
                  _message,
                  style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      color: Color(0xff191919),
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 252,
            height: 162,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset("assets/images/main_iv_record_frame.png"),
                Container(
                  width: 100,
                  height: 100,
                  child: GestureDetector(
                    onTapDown: _br.isNotRecording
                        ? (_) => setState(() {
                              _br.isRecording = !_br.isRecording;
                            })
                        : null,
                    onTapCancel: _br.isNotRecording
                        ? () => setState(() {
                              _br.isRecording = !_br.isRecording;
                            })
                        : null,
                    onTap: _br.isNotRecording
                        ? () async {
                      if (await checkAndRequestPermission(context)) {
                        if (BasicTestClient.clntSocket == null) {
                          ToastGenerator.displayRegularMsg("연결에 실패했습니다.");
                          print("Connection refused");
                          setState(() {
                            _br.isNotRecording = true;
                            _br.isRecording = false;
                          });
                        } else {
                          setState(() {
                            _br.isNotRecording = !_br.isNotRecording;
                          });

                          setState(() {
                            _time = 0;
                            _timeText = "00:00";

                            _timer = Timer.periodic(
                                const Duration(seconds: 1), (timer) {
                              _time += 1;
                              _timeText = sprintf(
                                  "%02d:%02d", [_time ~/ 60, _time % 60]);
                            });
                          });

                          await _br.startRecording(_filePathForRecord);
                        }
                      } else {
                        setState(() {
                          _br.isRecording = false;
                        });
                      }
                    }
                        : null,
                    child: _br.isRecording
                        ? Image.asset(
                            "assets/images/main_btn_record_pressed.png",
                            gaplessPlayback: true,
                          )
                        : Image.asset(
                            "assets/images/main_btn_record.png",
                            gaplessPlayback: true,
                          ),
                  ),
                ),
                Container(
                    width: 42,
                    height: 42,
                    margin: const EdgeInsets.fromLTRB(162, 16, 0, 0),
                    child: GestureDetector(
                      onTapDown: _br.isRecording
                          ? (_) => setState(() {
                                _br.isNotRecording = !_br.isNotRecording;
                              })
                          : null,
                      onTapCancel: _br.isRecording
                          ? () => setState(() {
                                _br.isNotRecording = !_br.isNotRecording;
                              })
                          : null,
                      onTap: _br.isRecording
                          ? () => setState(() async {
                                _br.isRecording = !_br.isRecording;
                                await _br.stopRecording();

                                // 파일 리스트 갱신
                                _fl.fileList = _fl.loadFiles();
                                _setPathForRecord();
                                if (_fl.fileList.length == 1) {
                                  _fl.selectedFile = _fl.fileList[0];
                                }

                                _timer.cancel();
                                await _sendData();
                                // await _stopCon();
                              })
                          : null,
                      child: _br.isNotRecording
                          ? Image.asset(
                              "assets/images/main_btn_stop_pressed.png",
                              gaplessPlayback: true,
                            )
                          : Image.asset(
                              "assets/images/main_btn_stop.png",
                              gaplessPlayback: true,
                            ),
                    ))
              ],
            ),
          ),
        ],
      );
    }

    Widget _buildWholeComponents() {
      // 화면 크기에 따라 스크롤뷰 적용 여부 결정
      if (MediaQuery.of(context).size.height < 670) {
        return Scaffold(
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
                  child: _buildMainComponents(),
                )));
      } else {
        return Scaffold(
            body: Container(
                margin: const EdgeInsets.fromLTRB(0, 26, 0, 0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xffffffff), Color(0xfff2f2f2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
                child: _buildMainComponents()));
      }
    }

    return _buildWholeComponents();
  }

  void _initializer() async {
    await _br.init();
    await _setUser();
    await _setServAddr();

    _client.setServAddr(_serv.servIPAddr!, int.parse(_serv.servPort!));

    // 내부저장소 경로 로드
    var docsDir = await getApplicationDocumentsDirectory();
    _fl.storagePath = docsDir.path;
    setState(() {
      // 파일 리스트 초기화
      _fl.fileList = _fl.loadFiles();
      _setPathForRecord();
    });
    // _filePathForWaveVisualize = '${_fl.storagePath}/waveform.wav';
    if (_fl.fileList.isNotEmpty) {
      _fl.selectedFile = _fl.fileList[0];
    }

    // 녹음 위한 FlutterSoundRecorder 객체 설정
    _br.setRecordingSession();

    // 무조건 재설정
    _resetServCon();
  }

  _setUser() async {
    _user = UserInfo();
    await _user.setPrefs();
    _user.loadUserInfo();
    setState(() {
      _userName = _user.userName!;
    });
  }

  _setServAddr() async {
    _serv = ServerInfo();
    await _serv.setPrefs();
    _serv.loadServerInfo();
  }

  _setPathForRecord() {
    _filePathForRecord = '${_fl.storagePath}/sample 0.wav'; // 파일 고정
  }

  Future<bool> _startCon() async {
    try {
      await _client.sendRequest();
    } on SocketException {
      ToastGenerator.displayRegularMsg("연결에 실패했습니다. - 관리자페이지에서 주소 재설정 필요");
      setState(() {
        BasicTestClient.clntSocket = null;
      });
      print("Connection refused");

      return false;
    } on Exception {
      print("Unexpected exception");

      return false;
    }

    // 이름 전송
    _client.sendID(3);

    setState(() {
      _state = "Connected";
    });
    if (BasicTestClient.clntSocket != null) {
      BasicTestClient.clntSocket!.listen((List<int> event) {
        setState(() {
          if (_state == FIN_CODE) {
            print("time elapsed: ${stopwatch.elapsed}");
          }

          int header = DecodingMessage.decodingMsg(event);
          int msgSize = event[2];

          if (header == 128) {
            print(event[3]);
            if (event[3] == 0) {
              print("비정상");
            } else if (event[3] == 1) {
              print("정상");

              int dataSize = msgSize - 1;
              _message = utf8.decode(event.sublist(4, dataSize));
            } else {
              print("잘못된 상태코드");
            }
          }
        });
      });
    }

    return true;
  }

  Future<void> _sendData() async {
    try {
      Uint8List data =
          await _fl.readFile("${_fl.storagePath}/${_fl.selectedFile}");
      stopwatch = Stopwatch()..start();
      _client.sendFile(1, data); // 임시 - 타입 1
    } on FileSystemException {
      print("File not exists: ${_fl.selectedFile}");
    }
  }

  Future<void> _stopCon() async {
    _client.stopClnt();
    setState(() {
      _state = "Disconnected";
    });
  }

  _resetServCon() async {
    if (BasicTestClient.clntSocket != null) {
      await _stopCon();
    }
    bool chk = await _startCon();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // _br.recorderController.dispose();
    super.dispose();
  }
}
