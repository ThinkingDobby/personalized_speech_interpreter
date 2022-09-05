import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sprintf/sprintf.dart';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:personalized_speech_interpreter/tcpClients/FileTransferTestClient.dart';

import 'file/FileLoader.dart';
import 'main.dart';

class MainPage extends StatefulWidget {
  @override
  State createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isRecording = false;
  bool _isNotRecording = true;
  bool _isPlaying = false;

  int _time = 0;
  String _timeText = "00:00";
  String _message = "거실 불 켜";

  String _state = "Unconnected";
  final String FIN_CODE = "Transfer Finished";

  // 녹음 위한 객체 저장
  late FlutterSoundRecorder _recordingSession;

  // 음성 신호 시각화 위한 객체 저장
  late RecorderController _recorderController;

  // 재생 위한 객체 저장
  final _audioPlayer = AssetsAudioPlayer();

  // 녹음 위한 파일 경로 (저장소 경로 + 파일명)
  late String _filePathForRecord;
  late String _filePathForWaveVisualize;

  // 파일 로드, 삭제 위한 객체
  final _fl = FileLoader();

  late Timer _timer;

  late FileTransferTestClient _client;

  // 실행 시간 측정 위한 객체
  late Stopwatch stopwatch;

  @override
  void initState() {
    super.initState();
    _client = FileTransferTestClient();
    _initializer();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildMainComponents() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Builder(
                        builder: (context) {
                          return InkWell(
                              onDoubleTap: () {
                                if (!_isRecording) {
                                  Navigator.pushNamed(context, TEST_PAGE);
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "음성 입력 중에는 이동이 불가능합니다.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: const Color(0xff999999),
                                      textColor: const Color(0xfffefefe),
                                      fontSize: 16.0);
                                }
                              },
                              child: Image.asset("assets/images/icon.png"));
                        },
                      )),
                  if (MediaQuery.of(context).size.height >= 670) const Spacer(),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 16, 16, 0),
                    child: Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: InkWell(
                          onTap: () {
                            if (!_isRecording) {
                              Navigator.pushNamed(context, TRAINING_PAGE);
                            } else {
                              Fluttertoast.showToast(
                                  msg: "음성 입력 중에는 이동이 불가능합니다.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Color(0xff999999),
                                  textColor: Color(0xfffefefe),
                                  fontSize: 16.0);
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
                          "이치호",
                          style: TextStyle(
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
          if (MediaQuery.of(context).size.height >= 670) const Spacer() else const SizedBox(height: 16),
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
                  recorderController: _recorderController,
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
                margin: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                alignment: Alignment.center,
                width: 296,
                height: 96,
                child: Text(
                  _message,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    color: Color(0xff000000),
                  ),
                  softWrap: false,
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
                    onTapDown: _isNotRecording
                        ? (_) => setState(() {
                              _isRecording = !_isRecording;
                            })
                        : null,
                    onTapCancel: _isNotRecording
                        ? () => setState(() {
                              _isRecording = !_isRecording;
                            })
                        : null,
                    onTap: _isNotRecording
                        ? () => setState(() {
                              _isNotRecording = !_isNotRecording;
                              _startRecording();
                            })
                        : null,
                    child: _isRecording
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
                      onTapDown: _isRecording
                          ? (_) => setState(() {
                                _isNotRecording = !_isNotRecording;
                              })
                          : null,
                      onTapCancel: _isRecording
                          ? () => setState(() {
                                _isNotRecording = !_isNotRecording;
                              })
                          : null,
                      onTap: _isRecording
                          ? () => setState(() {
                                _isRecording = !_isRecording;
                                _stopRecording();
                              })
                          : null,
                      child: _isNotRecording
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
            child: buildMainComponents(),
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
          child: buildMainComponents()));
    }
  }

  void _initializer() async {
    _recorderController = RecorderController();
    // 내부저장소 경로 로드
    var docsDir = await getApplicationDocumentsDirectory();
    _fl.storagePath = docsDir.path;
    setState(() {
      // 파일 리스트 초기화
      _fl.fileList = _fl.loadFiles();
      _setPathForRecord();
    });
    _filePathForWaveVisualize = '${_fl.storagePath}/waveform.wav';
    if (_fl.fileList.isNotEmpty) {
      _fl.selectedFile = _fl.fileList[0];
    }

    // 녹음 위한 FlutterSoundRecorder 객체 설정
    _setRecordingSession();
  }

  _setPathForRecord() {
    _filePathForRecord = '${_fl.storagePath}/input.wav'; // 파일 고정
  }

  RadioListTile _setListItemBuilder(BuildContext context, int i) {
    return RadioListTile(
        title: Text(_fl.fileList[i]),
        value: _fl.fileList[i],
        groupValue: _fl.selectedFile,
        onChanged: (val) {
          setState(() {
            _fl.selectedFile = _fl.fileList[i];
          });
        });
  }

  _setRecordingSession() async {
    // 객체 설정
    _recordingSession = FlutterSoundRecorder();
    await _recordingSession.openAudioSession(
        focus: AudioFocus.requestFocusAndStopOthers,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);
    await _recordingSession
        .setSubscriptionDuration(const Duration(milliseconds: 10));
    await initializeDateFormatting();

    // 권한 요청
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  Future<void> _startRecording() async {
    // print("start recording");
    // print("filePathForRecording: ${_filePathForRecord}");
    Directory directory = Directory(dirname(_filePathForRecord));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    _recordingSession.openAudioSession();
    // 녹음 시작
    await _recordingSession.startRecorder(
      toFile: _filePathForRecord,
      codec: Codec.pcm16WAV,
    );

    await _recorderController.record(); // 경로 임시 제거 - 기본 경로: git log 참고

    setState(() {
      _time = 0;
      _timeText = "00:00";
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _time += 1;
        _timeText = sprintf("%02d:%02d", [_time ~/ 60, _time % 60]);
      });
    });
  }

  Future<String?> _stopRecording() async {
    // print("stop recording");
    // 녹음 중지
    _recordingSession.closeAudioSession();
    await _recorderController.pause();

    setState(() {
      // 파일 리스트 갱신
      _fl.fileList = _fl.loadFiles();
      _setPathForRecord();
      if (_fl.fileList.length == 1) {
        _fl.selectedFile = _fl.fileList[0];
      }
    });

    _timer.cancel();

    await _recordingSession.stopRecorder();
    await _startCon();
    await _sendData();
    await _stopCon();
  }

  Future<void> _startPlaying() async {
    // 재생
    _audioPlayer.open(
      Audio.file('${_fl.storagePath}/${_fl.selectedFile}'),
      autoStart: true,
      showNotification: true,
    );
    // print("filePathForPlaying ${_fl.storagePath}/${_fl.selectedFile}");
    _audioPlayer.playlistAudioFinished.listen((event) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  Future<void> _stopPlaying() async {
    // 재생 중지
    _audioPlayer.stop();
  }

  Future<void> _startCon() async {
    await _client.sendRequest();
    setState(() {
      _state = "Connected";
    });
    _client.clntSocket.listen((List<int> event) {
      setState(() {
        _state = utf8.decode(event);
        if (_state == FIN_CODE) {
          _client.clntSocket.done;
          print("time elapsed: ${stopwatch.elapsed}");
        }
      });
    });
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

  @override
  void dispose() {
    _recorderController.dispose();
    super.dispose();
  }
}
