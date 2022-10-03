import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personalized_speech_interpreter/prefs/ServerInfo.dart';
import 'package:personalized_speech_interpreter/soundUtils/BasicRecorder.dart';
import 'package:personalized_speech_interpreter/tcpClients/BasicTestClient.dart';
import 'package:personalized_speech_interpreter/tcpClients/FileTransferTestClient.dart';
import 'package:personalized_speech_interpreter/utils/ToastGenerator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/TrainingLabel.dart';
import 'file/FileLoader.dart';
import 'main.dart';

class SentencesPage extends StatefulWidget {
  @override
  State createState() => _SentencesPageState();
}

class _SentencesPageState extends State<SentencesPage> with WidgetsBindingObserver {
  final BasicRecorder _br = BasicRecorder();

  bool _isSending = false;
  bool _isSendBtnClicked = false;
  bool _isSendAvailable = false;

  bool _isControlActivated = false;
  bool _cancelBtnPressed = false;

  String _state = "Unconnected";
  final String FIN_CODE = "Transfer Finished";

  // 녹음 위한 파일 경로 (저장소 경로 + 파일명)
  late String _filePathForRecord;

  // late String _filePathForWaveVisualize;
  late Directory docsDir;

  // 파일 로드, 삭제 위한 객체
  final _fl = FileLoader();

  late FileTransferTestClient _client;

  // 단어 리스트
  List<String> words = TrainingLabel.words;
  String? _selectedWord;
  final Map<String, bool> _wordTrained = {};
  List<String> _trainedWords = [];

  late SharedPreferences _wordPrefs;

  TextEditingController searchTextController = TextEditingController();

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 48),
                    Container(
                      width: 326,
                      height: 40,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              if (_br.isRecording) {
                                ToastGenerator.displayRegularMsg(
                                    "녹음 중에는 이동이 불가능합니다.");
                              } else {
                                await Navigator.pushNamedAndRemoveUntil(
                                    context, MAIN_PAGE, (route) => false);
                              }
                            },
                            child: Image.asset(
                                "assets/images/training_btn_back.png"),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '문장학습',
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
                                margin:
                                    const EdgeInsets.fromLTRB(0, 0, 16, 0),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  child: Image.asset(
                                      "assets/images/main_icon_sync_dis.png"),
                                )
                            ),
                        ],
                      )
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: 296,
                      child: const Text(
                        "학습 시킬 문장을 선택해주세요.\n이미 학습된 문장을 다시 학습 시키는 것도 가능합니다.",
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          color: Color(0xff676767),
                          fontWeight: FontWeight.w400,
                        ),
                        softWrap: true,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Stack(
                      children: [
                        Container(
                          width: 296,
                          height: 40,
                          child: Image.asset(
                              "assets/images/sentences_iv_search_background.png"),
                        ),
                        Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.all(9),
                          child: Image.asset("assets/images/sentences_iv_search.png"),
                        ),
                        Container(
                          width: 296,
                          height: 40,
                          child: TextFormField(
                            controller: searchTextController,
                            decoration: const InputDecoration(
                                isDense: true,
                                contentPadding:
                                EdgeInsets.fromLTRB(40, 11, 24, 10),
                                hintText: "검색어를 입력하세요.",
                                hintStyle: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  color: Color(0xff676767),
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none
                            ),
                            cursorColor: Color(0xef8d7c),
                          ),
                        )
                      ]
                    ),
                  ]
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

    for (var word in TrainingLabel.words) {
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

    _wordTrained[_selectedWord!] = true;
    _trainedWords.add(_selectedWord!);
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
      _client.sendFile(1, data); // 임시 - 타입 1
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

  void _deleteFile(i) {
    setState(() {
      _fl.selectedFile = _fl.fileList[i];
    });
    _fl.deleteFile("${_fl.storagePath}/${_fl.selectedFile}");
    setState(() {
      _fl.fileList = _fl.loadFiles();
      // _checkSendAvailable();
      _setPathForRecord();
    });
  }

  Future<bool> _onBack() async {
    if (_br.isRecording) {
      ToastGenerator.displayRegularMsg("녹음 중에는 이동이 불가능합니다.");
      await Navigator.pushNamedAndRemoveUntil(
          context, MAIN_PAGE, (route) => false);
      return false;
    } else {
      await Navigator.pushNamedAndRemoveUntil(
          context, MAIN_PAGE, (route) => false);
      return true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _br.recorderController.dispose();
    searchTextController.dispose();
    super.dispose();
  }
}
