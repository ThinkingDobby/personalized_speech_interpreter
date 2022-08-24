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

import 'package:flutter_sound/flutter_sound.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:personalized_speech_interpreter/tcpClients/FileTransferTestClient.dart';

import 'file/FileLoader.dart';


class TrainingPage extends StatefulWidget {
  @override
  State createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  bool _isSending = false;
  bool _isSendBtnClicked = false;

  bool _isRecording = false;
  bool _isNotRecording = true;
  bool _isPlaying = false;

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

  late FileTransferTestClient _client;

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
                      const SizedBox(height: 64),
                      Container(
                        margin: const EdgeInsets.fromLTRB(32, 0, 0, 0),
                        width: 296,
                        height: 40,
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
                      // 단어 선택창
                      const SizedBox(height: 72),
                      Container(
                        alignment: Alignment.topCenter,
                        width: 320,
                        height: 446,
                        child: Stack(
                          children: [
                            SizedBox(
                                width: 316,
                                height: 400,
                                child: Image.asset(
                                    "assets/images/training_iv_list_background.png")),
                            Container(
                                margin: const EdgeInsets.fromLTRB(0, 348, 0, 0),
                                width: 320,
                                height: 98,
                                child: Image.asset(
                                    "assets/images/training_iv_control.png")),
                            Container(
                              margin: const EdgeInsets.fromLTRB(26, 365, 0, 0),
                              width: 97,
                              height: 50,
                              alignment: Alignment.center,
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
                                size: Size(MediaQuery.of(context).size.width, 40.0),
                                recorderController: _recorderController,
                              ),
                            ),
                            Container(
                                margin:
                                    const EdgeInsets.fromLTRB(138, 366, 0, 0),
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 52,
                                      height: 52,
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
                                                  _isNotRecording =
                                                      !_isNotRecording;
                                                  _startRecording();
                                                })
                                            : null,
                                        child: _isRecording
                                            ? Image.asset(
                                                "assets/images/training_btn_record_pressed.png",
                                                gaplessPlayback: true,
                                              )
                                            : Image.asset(
                                                "assets/images/training_btn_record.png",
                                                gaplessPlayback: true,
                                              ),
                                      ),
                                    ),
                                    Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            2, 0, 0, 0),
                                        width: 52,
                                        height: 52,
                                        child: GestureDetector(
                                          onTapDown: _isRecording
                                              ? (_) => setState(() {
                                                    _isNotRecording =
                                                        !_isNotRecording;
                                                  })
                                              : null,
                                          onTapCancel: _isRecording
                                              ? () => setState(() {
                                                    _isNotRecording =
                                                        !_isNotRecording;
                                                  })
                                              : null,
                                          onTap: _isRecording
                                              ? () => setState(() {
                                                    _isRecording =
                                                        !_isRecording;
                                                    _stopRecording();
                                                  })
                                              : null,
                                          child: _isNotRecording
                                              ? Image.asset(
                                                  "assets/images/training_btn_stop_pressed.png",
                                                  gaplessPlayback: true,
                                                )
                                              : Image.asset(
                                                  "assets/images/training_btn_stop.png",
                                                  gaplessPlayback: true,
                                                ),
                                        )),
                                    Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(2, 0, 0, 0),
                                      width: 52,
                                      height: 52,
                                      child: Image.asset(
                                          "assets/images/training_btn_stop.png"),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 64),
                      Container(
                        child: Stack(
                          children: [
                            Container(
                              width: 332,
                              height: 66,
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
                            Container(
                              width: 332,
                              height: 62,
                              alignment: Alignment.center,
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
                          ],
                        )
                      ),
                      const SizedBox(height: 12),
                    ])
            )
        )
    );
  }

  void _initializer() async {
    _recorderController = RecorderController();
    // 내부저장소 경로 로드
    var docsDir = await getApplicationDocumentsDirectory();
    _fl.storagePath = '${docsDir.path}/recorded_files';
    setState(() {
      // 파일 리스트 초기화
      _fl.fileList = _fl.loadFiles();
      _setPathForRecord();
    });
    _filePathForWaveVisualize = '${docsDir.path}/waveform.wav';
    if (_fl.fileList.isNotEmpty) {
      _fl.selectedFile = _fl.fileList[0];
    }

    // 녹음 위한 FlutterSoundRecorder 객체 설정
    _setRecordingSession();
  }

  _setPathForRecord() {
    _filePathForRecord =
        '${_fl.storagePath}/temp${_fl.fileList.length + 1}.wav';
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
    await _recorderController.record();
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

    await _recordingSession.stopRecorder();
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

  Future<void> _startSend() async {
    setState(() {
      _isSending = true;
    });

    // await _startCon();
    // await _sendData();
    // await _stopCon();

    setState(() {
      _isSending = false;
      _isSendBtnClicked = false;
    });
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
        }
      });
    });
  }

  Future<void> _sendData() async {
    try {
      Uint8List data =
          await _fl.readFile("${_fl.storagePath}/${_fl.selectedFile}");
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
