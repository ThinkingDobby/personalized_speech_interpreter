import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personalized_speech_interpreter/dialog/LearningDialog.dart';
import 'package:personalized_speech_interpreter/prefs/ServerInfo.dart';
import 'package:personalized_speech_interpreter/soundUtils/BasicRecorder.dart';
import 'package:personalized_speech_interpreter/tcpClients/BasicTestClient.dart';
import 'package:personalized_speech_interpreter/tcpClients/FileTransferTestClient.dart';
import 'package:personalized_speech_interpreter/utils/ToastGenerator.dart';
import 'package:personalized_speech_interpreter/utils/getSearchedList.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/TrainingLabel.dart';
import 'file/FileLoader.dart';
import 'main.dart';

class SentencesPage extends StatefulWidget {
  @override
  State createState() => _SentencesPageState();
}

class _SentencesPageState extends State<SentencesPage> with WidgetsBindingObserver {
  String _state = "Unconnected";
  final String FIN_CODE = "Transfer Finished";

  late Directory docsDir;

  // 파일 로드, 삭제 위한 객체
  final _fl = FileLoader();

  late FileTransferTestClient _client;

  // 단어 리스트
  List<String> _words = TrainingLabel.words;
  final Map<String, bool> _wordTrained = {};
  List<String> _trainedWords = [];
  List<String> _searchedWords = [];

  late SharedPreferences _wordPrefs;

  final TextEditingController _searchTextController = TextEditingController();
  FocusNode textFocus = FocusNode();

  late ServerInfo _serv;

  bool _isSocketExists = false;

  bool _isDialogActivated = false;

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
        if (!_isDialogActivated) {
          _startCon();
          Timer(const Duration(seconds: 1), () {
            setState(() {
              _isSocketExists = BasicTestClient.clntSocket != null;
            });
          });
        }
        break;
      case AppLifecycleState.inactive:
        if (!_isDialogActivated) {
          _stopCon();
        }
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (){
      textFocus.unfocus();
    },
    child: WillPopScope(
        onWillPop: () async {
          await Navigator.pushNamedAndRemoveUntil(context, MAIN_PAGE, (route) => false);
          return true;
    },
    child: Scaffold(
            resizeToAvoidBottomInset: false,
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
                        "학습시킬 문장을 선택해주세요.\n이미 학습된 문장을 다시 학습시키는 것도 가능합니다.",
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
                            controller: _searchTextController,
                            focusNode: textFocus,
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
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        width: 312,
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _searchedWords.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              childAspectRatio: 156/100,
                            ),
                            itemBuilder: (context, i) => _setGridItemBuilder(context, i)
                          ),
                        )
                      )
                    ),
                  ]
                )
            )
    )));
  }

  void _initializer() async {
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
    });
    // _filePathForWaveVisualize = '${docsDir.path}/waveform.wav';
    if (_fl.fileList.isNotEmpty) {
      _fl.selectedFile = _fl.fileList[0];
    }

    await _initWordTrained();

    _searchedWords = getSearchedList(_words, _searchTextController) as List<String>;
    _searchTextController.addListener(() {
      setState(() {
        _searchedWords = getSearchedList(_words, _searchTextController) as List<String>;
      });
    });
  }

  _setServAddr() async {
    _serv = ServerInfo();
    await _serv.setPrefs();
    _serv.loadServerInfo();
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

  Future<bool> _startCon() async {
    try {
      await _client.sendRequest();
    } on SocketException {
      setState(() {
        BasicTestClient.clntSocket = null;
        _isSocketExists = BasicTestClient.clntSocket != null;
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

  // GestureDetector 적용 필요
  GestureDetector _setGridItemBuilder(BuildContext ctx, int i) {
    return GestureDetector(
      onTap: _wordTrained[_searchedWords[i]]! ? () => ToastGenerator.displayRegularMsg("이미 학습된 단어입니다.")
      : () async {
        if (FocusManager.instance.primaryFocus! is FocusScopeNode) {
          await _showLearningDialog(ctx, i);
          _resetServCon();
          setState(() {
            _initWordTrained();
          });
        } else {
          FocusManager.instance.primaryFocus
              ?.unfocus();
        }
      },
      child: Container(
        width: 156,
        height: 100,
        child: Stack(
          children: [
            Container(
                width: 156,
                height: 100,
                child: Image.asset("assets/images/sentences_iv_word.png")
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 3),
              child: Text(
                _searchedWords[i],
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  color: Color(0xff191919),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
                height: 18,
                alignment: Alignment.topRight,
                margin: const EdgeInsets.fromLTRB(0, 14, 18, 0),
                child: Visibility(
                  child: Image.asset("assets/images/sentences_iv_check.png"),
                  visible: _wordTrained[_searchedWords[i]] ?? false,
                )
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showLearningDialog(context, i) async {
    _isDialogActivated = true;
    await showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LearningDialog(i);
        });
    _isDialogActivated = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchTextController.dispose();
    super.dispose();
  }
}
