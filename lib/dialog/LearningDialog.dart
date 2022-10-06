import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personalized_speech_interpreter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/TrainingLabel.dart';
import '../file/FileLoader.dart';
import '../prefs/ServerInfo.dart';
import '../prefs/UserInfo.dart';
import '../soundUtils/BasicRecorder.dart';
import '../tcpClients/BasicTestClient.dart';
import '../tcpClients/FileTransferTestClient.dart';
import '../utils/ToastGenerator.dart';

class LearningDialog extends StatefulWidget {
  int _idx;

  LearningDialog(this._idx);

  @override
  State createState() => _LearningDialogState(_idx);
}

class _LearningDialogState extends State<LearningDialog> with WidgetsBindingObserver{
  int _wordIdx;
  _LearningDialogState(this._wordIdx);

  final BasicRecorder _br = BasicRecorder();

  bool _isSending = false;
  bool _isSendBtnClicked = false;
  bool _isSendAvailable = false;

  bool _cancelBtnPressed = false;

  String _state = "Unconnected";
  final String FIN_CODE = "Transfer Finished";

  // 녹음 위한 파일 경로 (저장소 경로 + 파일명)
  late String _filePathForRecord;

  late String _filePathForWaveVisualize;
  late Directory docsDir;

  // 파일 로드, 삭제 위한 객체
  final _fl = FileLoader();

  late FileTransferTestClient _client;

  // 단어 리스트
  List<String> _words = TrainingLabel.words;
  final Map<String, bool> _wordTrained = {};
  List<String> _trainedWords = [];

  late SharedPreferences _wordPrefs;

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
        onWillPop: () {
          return _onBack();
        },
    child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        contentPadding: EdgeInsets.zero,
        backgroundColor: const Color(0x00ffffff),
        content: Container(
            width: 296,
            height: 477,
            child: Stack(
              children: [
                Container(
                    height: 477,
                    child: Image.asset("assets/images/learning_iv_background.png", fit: BoxFit.fill,)
                ),
                Column(
                  children: [
                    Container(
                        height: 32,
                        alignment: Alignment.topRight,
                        margin: const EdgeInsets.fromLTRB(0, 16, 16, 0),
                        child: Theme(
                          data: ThemeData(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent
                          ),
                          child: InkWell(
                            child: Image.asset("assets/images/learning_btn_cancel.png"),
                            onTap: () => _onBack(),
                          ),
                        )
                    ),
                    const SizedBox(height: 16),
                    Container(
                        child: Text(
                          _words[_wordIdx] ?? "문장이 설정되지 않았습니다.",
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 22,
                            color: Color(0xff191919),
                            fontWeight: FontWeight.w600,
                          ),
                        )
                    ),
                    const SizedBox(height: 44),
                    Container(
                      width: 110,
                      height: 110,
                      child: Image.asset("assets/images/learning_iv_book.png"),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      child: Text(
                        "총 10회의 녹음을 진행합니다.\n버튼을 눌러 녹음을 시작해주세요.",
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          color: Color(0xff191919),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 44),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Text(
                          _fl.fileList.length.toString(),
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            color: const Color(0xffDB8278),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          '/10',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            color: Color(0xff191919),
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8)
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: 250,
                      child: Row(
                        children: [
                          Container(
                            width: 117,
                            alignment: Alignment.center,
                            child: Stack(
                              children: [
                                Container(
                                  width: 101,
                                  height: 50,
                                  child: Image.asset("assets/images/learning_iv_panel_signal.png"),
                                ),
                                Container(
                                  width: 101,
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
                                    recorderController: _br.recorderController,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 125,
                            alignment: Alignment.center,
                            child: Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                                  child: Image.asset("assets/images/learning_iv_panel_record.png"),
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(12, 9, 0, 0),
                                  width: 52,
                                  height: 52,
                                  child: GestureDetector(
                                    onTapDown: _br.isNotRecording
                                        ? (_) => setState(() {
                                      _br.isRecording =
                                      !_br.isRecording;
                                    })
                                        : null,
                                    onTapCancel: _br.isNotRecording
                                        ? () => setState(() {
                                      _br.isRecording =
                                      !_br.isRecording;
                                    })
                                        : null,
                                    onTap: _br.isNotRecording
                                        ? () => setState(() {
                                      _br.isNotRecording =
                                      !_br.isNotRecording;
                                      _br.startRecording(
                                          _filePathForRecord);
                                    })
                                        : null,
                                    child: _br.isRecording
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
                                  margin: const EdgeInsets.fromLTRB(64, 9, 0, 0),
                                  width: 52,
                                  height: 52,
                                  child: GestureDetector(
                                    onTapDown: _br.isRecording
                                        ? (_) => setState(() {
                                      _br.isNotRecording =
                                      !_br.isNotRecording;
                                    })
                                        : null,
                                    onTapCancel: _br.isRecording
                                        ? () => setState(() {
                                      _br.isNotRecording =
                                      !_br.isNotRecording;
                                    })
                                        : null,
                                    onTap: _br.isRecording
                                        ? () => setState(() {
                                      _br.isRecording =
                                      !_br.isRecording;
                                      _br.stopRecording();

                                      // 파일 리스트 갱신
                                      _fl.fileList =
                                          _fl.loadFiles();
                                      _setPathForRecord();
                                      if (_fl.fileList
                                          .length ==
                                          1) {
                                        _fl.selectedFile =
                                        _fl.fileList[0];
                                      }
                                    })
                                        : null,
                                    child: _br.isNotRecording
                                        ? Image.asset(
                                      "assets/images/training_btn_stop_pressed.png",
                                      gaplessPlayback: true,
                                    )
                                        : Image.asset(
                                      "assets/images/training_btn_stop.png",
                                      gaplessPlayback: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            )
        )
      )
    );
  }

  void _initializer() async {
    await _br.init();
    await _setServAddr();

    _client.setServAddr(_serv.servIPAddr!, int.parse(_serv.servPort!));

    // 무조건 재설정
    _resetServCon();
    _isSocketExists = BasicTestClient.clntSocket != null;

    // 내부저장소 경로 로드
    docsDir = await getApplicationDocumentsDirectory();
    _fl.storagePath = '${docsDir.path}/recorded_files';
    setState(() {
      // 파일 리스트 초기화
      _fl.fileList = _fl.loadFiles();
      _setPathForRecord();
    });
    // _filePathForWaveVisualize = '${docsDir.path}/waveform.wav';
    if (_fl.fileList.isNotEmpty) {
      _fl.selectedFile = _fl.fileList[0];
    }

    // 녹음 위한 FlutterSoundRecorder 객체 설정
    _br.setRecordingSession();

    await _initWordTrained();
    _setStoragePathWithWord(_words[_wordIdx]);
  }

  _setServAddr() async {
    _serv = ServerInfo();
    await _serv.setPrefs();
    _serv.loadServerInfo();
  }

  // 단어 선택 시 호출
  _setStoragePathWithWord(String word) {
    _fl.storagePath = '${docsDir.path}/recorded_files/$word';
    setState(() {
      _fl.fileList = _fl.loadFiles();
      // _checkSendAvailable();
      _setPathForRecord();
    });
  }

  _setPathForRecord() {
    _filePathForRecord = '${_fl.storagePath}/음성샘플 ${_fl.lastNum + 1}.wav';
  }

  _initWordTrained() async {
    _wordPrefs = await SharedPreferences.getInstance();

    for (var word in _words) {
      _wordTrained[word] = false;
    }
    _trainedWords = _wordPrefs.getStringList("trainedWords") ?? [];

    for (var word in _trainedWords) {
      _wordTrained[word] = true;
    }
  }

  Future<void> _startSend() async {
    setState(() {
      _isSending = true;
    });

    _wordTrained[_words[_wordIdx]] = true;
    _trainedWords.add(_words[_wordIdx]);
    _wordPrefs.setStringList("trainedWords", _trainedWords);
    // _checkSendAvailable();

    // await _sendData(); // 한 단어에 해당되는 파일들을 레이블과 함께 전송해야

    setState(() {
      _isSending = false;
      _isSendBtnClicked = false;
    });
  }

  Future<bool> _startCon() async {
    try {
      await _client.sendRequest();
    } on SocketException {
      setState(() {
        BasicTestClient.clntSocket = null;
        _isSocketExists = BasicTestClient.clntSocket != null;

        _isSending = false;
        _isSendBtnClicked = false;
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
    BasicTestClient.clntSocket!.listen((List<int> event) {
      setState(() {
        _state = utf8.decode(event);
        // 추후 동작 지정
      });
    });

    _isSocketExists = BasicTestClient.clntSocket != null;

    return true;
  }

  Future<void> _sendData() async {
    try {
      Uint8List data =
      await _fl.readFile("${_fl.storagePath}/${_fl.selectedFile}");
      _client.sendFile(1, data);
    } on FileSystemException {
      print("File not exists: ${_fl.selectedFile}");
    }

    if (BasicTestClient.clntSocket == null) {
      ToastGenerator.displayRegularMsg("연결에 실패했습니다.");
      print("Connection refused");
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

  Future<bool> _onBack() async {
    if (_br.isRecording) {
      ToastGenerator.displayRegularMsg("녹음 중에는 이동이 불가능합니다.");
      return false;
    } else {
      Navigator.pop(context);
      return true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _br.recorderController.dispose();
    super.dispose();
  }
}
