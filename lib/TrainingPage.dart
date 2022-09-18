import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personalized_speech_interpreter/data/TrainingLabel.dart';
import 'package:personalized_speech_interpreter/soundUtils/BasicPlayer.dart';
import 'package:personalized_speech_interpreter/soundUtils/BasicRecorder.dart';
import 'package:personalized_speech_interpreter/tcpClients/BasicTestClient.dart';
import 'package:personalized_speech_interpreter/tcpClients/FileTransferTestClient.dart';
import 'package:personalized_speech_interpreter/utils/ToastGenerator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'file/FileLoader.dart';

class TrainingPage extends StatefulWidget {
  @override
  State createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> with WidgetsBindingObserver {
  final BasicRecorder _br = BasicRecorder();
  final BasicPlayer _bp = BasicPlayer();

  bool _isSending = false;
  bool _isSendBtnClicked = false;
  bool _isSendAvailable = false;

  bool _isControlActivated = false;
  bool _cancelBtnPressed = false;

  String _message = "단어 또는 문장을 선택하세요.";

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

  TextEditingController dropDownTextController = TextEditingController();

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
        Timer(const Duration(seconds: 1), () {
          setState(() {
            _isSocketExists = BasicTestClient.clntSocket != null;
          });
        });
        break;
      case AppLifecycleState.inactive:
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
                child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
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
                                    onTap: () {
                                      if (_br.isRecording) {
                                        ToastGenerator.displayRegularMsg(
                                            "녹음 중에는 이동이 불가능합니다.");
                                      } else if (_bp.isPlaying) {
                                        _bp.stopPlaying();
                                        ToastGenerator.displayRegularMsg(
                                            "음성 재생이 중지되었습니다.");
                                        return Navigator.pop(context);
                                      } else {
                                        return Navigator.pop(context);
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
                          const SizedBox(height: 48),
                          Stack(
                            children: [
                              Container(
                                width: 296,
                                height: 40,
                                child: Image.asset(
                                    "assets/images/main_iv_word.png"),
                              ),
                              DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                buttonPadding:
                                    const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                dropdownElevation: 1,
                                isExpanded: true,
                                hint: Text(
                                  '단어 또는 문장을 선택하세요.',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                items: words
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontFamily: 'Pretendard',
                                              color: Color(0xff191919),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                value: _selectedWord,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedWord = value as String;
                                    _setStoragePathWithWord(value);
                                    _cancelBtnPressed = false;
                                    _isControlActivated = false;
                                    _message = _wordTrained[_selectedWord!]!
                                        ? "학습된 단어입니다."
                                        : "아직 학습되지 않은 단어입니다.";
                                  });
                                },
                                offset: const Offset(4, -4),
                                dropdownWidth: 284,
                                buttonHeight: 40,
                                buttonWidth: 296,
                                itemHeight: 40,
                                dropdownMaxHeight: 240,
                                searchController: dropDownTextController,
                                searchInnerWidget: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 4,
                                    right: 8,
                                    left: 8,
                                  ),
                                  child: TextFormField(
                                    controller: dropDownTextController,
                                    decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        hintText: '검색어를 입력해주세요.',
                                        hintStyle: const TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xffDB8278),
                                              width: 2.0),
                                        )),
                                  ),
                                ),
                                searchMatchFn: (item, searchValue) {
                                  return (item.value
                                      .toString()
                                      .contains(searchValue));
                                },
                                //This to clear the search value when you close the menu
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    dropDownTextController.clear();
                                  }
                                },
                              )),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            alignment: Alignment.topCenter,
                            width: 320,
                            height: 446,
                            child: Stack(
                              children: [
                                Container(
                                    width: 316,
                                    height: 90,
                                    child: Image.asset(
                                        "assets/images/training_iv_message_background.png")),
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 90, 0, 0),
                                    width: 316,
                                    height: 310,
                                    child: Image.asset(
                                        "assets/images/training_iv_list_background.png")),
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 110, 0, 0),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 16),
                                    width: 316,
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
                                            _setListItemBuilder(context, i)
                                      ),
                                    )),
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 348, 0, 0),
                                    width: 320,
                                    height: 98,
                                    child: Image.asset(
                                        "assets/images/training_iv_control.png")),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(26, 365, 0, 0),
                                  width: 97,
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: AudioWaveforms(
                                    waveStyle: WaveStyle(
                                      gradient: ui.Gradient.linear(
                                        const Offset(70, 50),
                                        Offset(
                                            MediaQuery.of(context).size.width /
                                                2,
                                            0),
                                        [
                                          const Color(0xffdc8379),
                                          const Color(0xfff5b6ae)
                                        ],
                                      ),
                                      showMiddleLine: false,
                                      extendWaveform: true,
                                    ),
                                    enableGesture: false,
                                    size: Size(
                                        MediaQuery.of(context).size.width,
                                        40.0),
                                    recorderController: _br.recorderController,
                                  ),
                                ),
                                Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        138, 366, 0, 0),
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(
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
                                            margin: const EdgeInsets.fromLTRB(
                                                2, 0, 0, 0),
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
                                                        _fl.fileList = _fl.loadFiles();
                                                        _checkSendAvailable();
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
                                            )),
                                        Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                2, 0, 0, 0),
                                            width: 52,
                                            height: 52,
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  0, 0, 0, 3),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    '${_fl.fileList.length}',
                                                    style: TextStyle(
                                                      fontFamily: 'Pretendard',
                                                      fontSize: 16,
                                                      color:
                                                          _fl.fileList.length ==
                                                                  10
                                                              ? const Color(
                                                                  0xffDB8278)
                                                              : const Color(
                                                                  0xff999999),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  const Text(
                                                    '/10',
                                                    style: TextStyle(
                                                      fontFamily: 'Pretendard',
                                                      fontSize: 16,
                                                      color: Color(0xff191919),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8)
                                                ],
                                              ),
                                            )
                                            // GestureDetector(
                                            //   onTapDown: (_) => setState(() {
                                            //     _cancelBtnPressed = true;
                                            //   }),
                                            //   onTapCancel: () => setState(() {
                                            //     _cancelBtnPressed = false;
                                            //   }),
                                            //   onTap: () => setState(() {
                                            //     _cancelBtnPressed = false;
                                            //     _isControlActivated = false;
                                            //     // 패널 비활성화
                                            //   }),
                                            //   child: _cancelBtnPressed
                                            //       ? Image.asset(
                                            //           "assets/images/training_btn_cancel_pressed.png",
                                            //           gaplessPlayback: true,
                                            //         )
                                            //       : Image.asset(
                                            //           "assets/images/training_btn_cancel.png",
                                            //           gaplessPlayback: true,
                                            //         ),
                                            // )
                                            ),
                                      ],
                                    )),
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 348, 0, 0),
                                    width: 320,
                                    height: 98,
                                    child: Visibility(
                                      visible: !_isControlActivated,
                                      child: Image.asset(
                                          "assets/images/training_iv_panel.png"),
                                    )),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(138, 366, 0, 0),
                                  width: 157,
                                  height: 52,
                                  child: Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(10, 0, 0, 3),
                                    width: 100,
                                    height: 52,
                                    alignment: Alignment.centerLeft,
                                    child: Visibility(
                                        visible: !_isControlActivated,
                                        child: Text(
                                          "음성샘플 추가",
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 16,
                                            color: _selectedWord != null
                                                ? const Color(0xffDB8278)
                                                : const Color(0xff999999),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )),
                                  ),
                                ),
                                Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        246, 366, 0, 0),
                                    width: 52,
                                    height: 52,
                                    child: _selectedWord != null
                                        ? Visibility(
                                            visible: !_isControlActivated,
                                            child: GestureDetector(
                                              onTapDown: (_) => setState(() {
                                                _cancelBtnPressed = true;
                                              }),
                                              onTapCancel: () => setState(() {
                                                _cancelBtnPressed = false;
                                              }),
                                              onTap: () => setState(() {
                                                _cancelBtnPressed = false;
                                                _isControlActivated = true;
                                                _checkSendAvailable();
                                                // 패널 활성화
                                              }),
                                              child: _cancelBtnPressed
                                                  ? Image.asset(
                                                      "assets/images/training_btn_add_pressed.png",
                                                      gaplessPlayback: true,
                                                    )
                                                  : Image.asset(
                                                      "assets/images/training_btn_add.png",
                                                      gaplessPlayback: true,
                                                    ),
                                            ))
                                        : GestureDetector(
                                            onTapDown: (_) => setState(() {
                                              ToastGenerator.displayRegularMsg(
                                                  '단어 또는 문장이 선택되지 않았습니다.');
                                            }),
                                            child: Image.asset(
                                                "assets/images/training_btn_add_disabled.png",
                                                gaplessPlayback: true),
                                          )),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 28, 0, 0),
                                  alignment: Alignment.center,
                                  width: 296,
                                  height: 32,
                                  child: Text(
                                    _message,
                                    style: const TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 16,
                                        color: Color(0xff191919),
                                        fontWeight: FontWeight.w500),
                                    softWrap: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          Container(
                              child: Stack(
                            children: [
                              Container(
                                  width: 332,
                                  height: 66,
                                  child: _isSendAvailable
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
                                              : () {
                                                  if (BasicTestClient
                                                          .clntSocket !=
                                                      null) {
                                                    _startSend();
                                                  } else {
                                                    setState(() {
                                                      _isSending = false;
                                                      _isSendBtnClicked = false;
                                                    });
                                                    ToastGenerator
                                                        .displayRegularMsg(
                                                            "연결에 실패했습니다.");
                                                  }
                                                },
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
                                            if (_selectedWord == null) {
                                              ToastGenerator.displayRegularMsg(
                                                  '단어 또는 문장이 선택되지 않았습니다.');
                                            } else if (!_isSendAvailable) {
                                              ToastGenerator.displayRegularMsg(
                                                  '음성샘플의 개수가 10개여야 합니다.');
                                            }
                                          }),
                                          child: Image.asset(
                                              "assets/images/training_btn_send_disabled.png",
                                              gaplessPlayback: true),
                                        )),
                              Container(
                                width: 332,
                                height: 62,
                                alignment: Alignment.center,
                                child: _isSendAvailable
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
                                            : () {
                                                if (BasicTestClient
                                                        .clntSocket !=
                                                    null) {
                                                  _startSend();
                                                } else {
                                                  setState(() {
                                                    _isSending = false;
                                                    _isSendBtnClicked = false;
                                                  });
                                                  ToastGenerator
                                                      .displayRegularMsg(
                                                          "연결에 실패했습니다.");
                                                }
                                              },
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
                                      )
                                    : const Text(
                                        '입력한 음성으로 학습',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 16,
                                          color: Color(0xffE7E7E7),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        softWrap: false,
                                      ),
                              ),
                            ],
                          )),
                          const SizedBox(height: 12),
                        ])))));
  }

  void _initializer() async {
    await _br.init();

    // 무조건 재설정
    _resetServAddr();
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

  _setStoragePathWithWord(String word) {
    _fl.storagePath = '${docsDir.path}/recorded_files/$word';
    setState(() {
      _fl.fileList = _fl.loadFiles();
      _checkSendAvailable();
      _setPathForRecord();
    });
  }

  _setPathForRecord() {
    _filePathForRecord =
        '${_fl.storagePath}/음성샘플 ${_fl.lastNum + 1}.wav';
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

  void _checkSendAvailable() {
    // print("_wordTrained: $_wordTrained");
    _fl.fileList = _fl.loadFiles();
    if (_fl.fileList.length == 10) {
      _isSendAvailable = true;
      _message =
          _wordTrained[_selectedWord!]! ? "학습된 단어이며 재학습이 가능합니다." : "학습이 가능합니다.";
    } else if (_wordTrained[_selectedWord!]!) {
      _isSendAvailable = false;
      _message = "학습된 단어입니다.";
    } else if (_fl.fileList.length < 10) {
      _isSendAvailable = false;
      _message = "음성샘플이 부족합니다.";
    } else {
      _isSendAvailable = false;
      _message = "음성샘플이 너무 많습니다.";
    }
  }

  RadioListTile _setListItemBuilder(BuildContext context, int i) {
    return RadioListTile(
        title: Row(
          children: [
            Text(_fl.fileList[i]),
            const Expanded(
                child: SizedBox(
              width: 0,
            )),
            IconButton(
                onPressed: () {
                  if (_br.isRecording) {
                    ToastGenerator.displayRegularMsg("녹음 중에는 재생이 불가능합니다.");
                  } else {
                    setState(() {
                      _bp.isPlaying = true;
                      _fl.selectedFile = _fl.fileList[i];
                    });
                    _bp.startPlaying("${_fl.storagePath}/${_fl.selectedFile}");
                  }
                },
                icon: Image.asset("assets/images/training_iv_play.png")),
            IconButton(
                onPressed: () {
                  if (_br.isRecording) {
                    ToastGenerator.displayRegularMsg("녹음 중에는 삭제가 불가능합니다.");
                  } else {
                    _deleteFile(i);
                  }
                },
                icon: Image.asset("assets/images/training_iv_delete.png"))
          ],
        ),
        value: _fl.fileList[i],
        groupValue: _fl.selectedFile,
        activeColor: const Color(0xffd55f52),
        onChanged: (val) {
          setState(() {
            _fl.selectedFile = _fl.fileList[i];
          });
        });
  }

  Future<void> _startSend() async {
    setState(() {
      _isSending = true;
    });

    _wordTrained[_selectedWord!] = true;
    _trainedWords.add(_selectedWord!);
    _wordPrefs.setStringList("trainedWords", _trainedWords);
    _checkSendAvailable();

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

  _resetServAddr() async {
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
      _checkSendAvailable();
      _setPathForRecord();
    });
  }

  Future<bool> _onBack() async {
    if (_br.isRecording) {
      ToastGenerator.displayRegularMsg("녹음 중에는 이동이 불가능합니다.");
      return false;
    } else if (_bp.isPlaying) {
      _bp.stopPlaying();
      ToastGenerator.displayRegularMsg("음성 재생이 중지되었습니다.");
      return true;
    } else {
      return true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _br.recorderController.dispose();
    dropDownTextController.dispose();
    super.dispose();
  }
}
