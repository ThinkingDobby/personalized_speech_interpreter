import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sprintf/sprintf.dart';

import 'package:adobe_xd/pinned.dart';

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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xffffffff), Color(0xfff2f2f2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: Stack(
          children: <Widget>[
            Container(
                margin: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                alignment: Alignment.topRight,
                child: Builder(
                  builder: (context) {
                    return InkWell(
                        onDoubleTap: () {
                          Navigator.pushNamed(context, TEST_PAGE);
                        },
                        child: Image.asset("assets/images/main_btn_null.png"));
                  },
                )),
            Pinned.fromPins(
              Pin(size: 252.0, middle: 0.5), Pin(size: 200.0, end: 16.0),
              child: Image.asset("assets/images/main_iv_record_frame.png"),
            ),
            Pinned.fromPins(
                Pin(size: 252, middle: 0.5), Pin(size: 200.0, end: 16.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget> [
                    Container(
                      width: 100,
                      height:100,
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                      child: GestureDetector(
                        onTapDown: _isNotRecording ? (_) => setState(() {
                          _isRecording = !_isRecording;
                        }) : null,
                        onTapCancel: _isNotRecording ? () => setState(() {
                          _isRecording = !_isRecording;
                        }) : null,
                        onTap: _isNotRecording ? () => setState(() {
                          _isNotRecording = !_isNotRecording;
                          _startRecording();
                        }) : null,
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
                        height:42,
                        margin: const EdgeInsets.fromLTRB(162, 0, 0, 0),
                        child: GestureDetector(
                          onTapDown: _isRecording ? (_) => setState(() {
                            _isNotRecording = !_isNotRecording;
                          }) : null,
                          onTapCancel: _isRecording ? () => setState(() {
                            _isNotRecording = !_isNotRecording;
                          }) : null,
                          onTap: _isRecording ? () => setState(() {
                            _isRecording = !_isRecording;
                            _stopRecording();
                          }) : null,
                          child: _isNotRecording
                              ? Image.asset(
                            "assets/images/main_btn_stop_pressed.png",
                            gaplessPlayback: true,
                          )
                              : Image.asset(
                            "assets/images/main_btn_stop.png",
                            gaplessPlayback: true,
                          ),
                        )
                    )
                  ],
                )
            ),
            Pinned.fromPins(
                Pin(start: 32.0, end: 32.0), Pin(size: 180.0, middle: 0.3645),
                child: Image.asset("assets/images/main_iv_signal.png")),
            Pinned.fromPins(
                Pin(start: 22, end: 22), Pin(size: 112.0, middle: 0.633),
                child: Image.asset("assets/images/main_iv_result_shadow.png")),
            Pinned.fromPins(
                Pin(start: 32.0, end: 32.0), Pin(size: 96.0, middle: 0.6222),
                child: Image.asset("assets/images/main_iv_result.png")),
            Align(
              alignment: Alignment(0.0, -0.656),
              child: SizedBox(
                width: 126.0,
                height: 68.0,
                child: Text(
                  _timeText,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 52,
                    color: Color(0xff676767),
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
                  _message,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    color: Color(0xff000000),
                  ),
                  softWrap: false,
                ),
              ),
            ),
            Pinned.fromPins(
              Pin(start: 32.0, end: 32.0), Pin(size: 180.0, middle: 0.3645),
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
                size: Size(MediaQuery.of(context).size.width, 180.0),
                recorderController: _recorderController,
              ),
            ),
            Container(
              alignment: Alignment.bottomRight,
              margin: const EdgeInsets.fromLTRB(0, 0, 16, 16),
              child: IconButton(
                icon: Image.asset("assets/images/icon.png"),
                onPressed: () => Navigator.pushNamed(context, TRAINING_PAGE),
              )
            )
           ],
        ),
      ),
    );
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
    setState((){
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
      Uint8List data = await _fl.readFile("${_fl.storagePath}/${_fl.selectedFile}");
      stopwatch = Stopwatch()..start();
      _client.sendFile(1, data);  // 임시 - 타입 1
    } on FileSystemException {
      print("File not exists: ${_fl.selectedFile}");
    }
  }

  Future<void> _stopCon() async {
    _client.stopClnt();
    setState((){
      _state = "Disconnected";
    });
  }

  @override
  void dispose() {
    _recorderController.dispose();
    super.dispose();
  }
}
