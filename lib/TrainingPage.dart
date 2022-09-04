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
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:personalized_speech_interpreter/data/TrainingLabel.dart';
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

  bool _isControlActivated = false;
  bool _cancelBtnPressed = false;

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
  late Directory docsDir;

  // 파일 로드, 삭제 위한 객체
  final _fl = FileLoader();

  late FileTransferTestClient _client;

  // 단어 리스트
  List<String> words = TrainingLabel.words;
  String? _selectedWord;

  TextEditingController dropDownTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _client = FileTransferTestClient();
    _initializer();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () {
      return _onBack();
    }, child:Scaffold(
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
                                  if (_isRecording) {
                                    _displayMsg("녹음 중에는 이동이 불가능합니다.");
                                  } else if (_isPlaying) {
                                    _stopPlaying();
                                    _displayMsg("음성 재생이 중지되었습니다.");
                                    return Navigator.pop(context);
                                  } else {
                                    return Navigator.pop(context);
                                  }
                                },
                                child: Image.asset("assets/images/training_btn_back.png"),
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
                            ],
                          )
                      ),
                      const SizedBox(height: 32),
                      Stack(
                        children: [
                          Container(
                            width: 296, height: 40,
                            child: Image.asset("assets/images/main_iv_word.png"),
                          ),
                          DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                buttonPadding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                dropdownElevation: 1,
                                isExpanded: true,
                                hint: Text(
                                  '단어 또는 문장을 선택해주세요.',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                items: words.map((item) => DropdownMenuItem<String>(
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
                                )
                                ).toList(),
                                value: _selectedWord,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedWord = value as String;
                                    _setStoragePathWithWord(value);
                                    _cancelBtnPressed = false;
                                    _isControlActivated = false;
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
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        hintText: '검색어를 입력해주세요.',
                                        hintStyle: const TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(color: Color(0xffDB8278), width: 2.0),
                                        )
                                    ),
                                  ),
                                ),
                                searchMatchFn: (item, searchValue) {
                                  return (item.value.toString().contains(searchValue));
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
                            SizedBox(
                                width: 316,
                                height: 400,
                                child: Image.asset(
                                    "assets/images/training_iv_list_background.png")),
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              width: 316,
                              height: 348,
                              child: ListView.builder(
                                // glow 제거
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: _fl.fileList.length,
                                itemBuilder: (context, i) =>
                                    _setListItemBuilder(context, i),
                              ),
                            ),
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
                                    Offset(
                                        MediaQuery.of(context).size.width / 2,
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
                                    MediaQuery.of(context).size.width, 40.0),
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
                                        margin: const EdgeInsets.fromLTRB(
                                            2, 0, 0, 0),
                                        width: 52,
                                        height: 52,
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 3),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${_fl.fileList.length}',
                                                style: TextStyle(
                                                  fontFamily: 'Pretendard',
                                                  fontSize: 16,
                                                  color: _fl.fileList.length == 10 ? const Color(0xffDB8278) : const Color(0xff999999),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const Text(
                                                '/10',
                                                style: TextStyle(
                                                  fontFamily: 'Pretendard',
                                                  fontSize: 16,
                                                  color: Color(0xff191919),
                                                  fontWeight: FontWeight.w400,
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
                                margin: const EdgeInsets.fromLTRB(0, 348, 0, 0),
                                width: 320,
                                height: 98,
                                child: Visibility(
                                  visible: !_isControlActivated,
                                  child: Image.asset(
                                      "assets/images/training_iv_panel.png"),
                                )),
                            Container(
                              margin: const EdgeInsets.fromLTRB(138, 366, 0, 0),
                              width: 157,
                              height: 52,
                              child:
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(10, 0, 0, 3),
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
                                            color: _selectedWord != null ? const Color(0xffDB8278) : const Color(0xff999999),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )),
                                  ),


                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(246, 366, 0, 0),
                              width: 52,
                              height: 52,
                              child: _selectedWord != null ? Visibility(
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
                                  )) : GestureDetector(
                                      onTapDown: (_) => setState(() {
                                        Fluttertoast.showToast(
                                            msg: "단어 또는 문장을 선택해주세요.",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Color(0xff999999),
                                            textColor: Color(0xfffefefe),
                                            fontSize: 16.0);
                                      }),
                                      child:Image.asset("assets/images/training_btn_add_disabled.png", gaplessPlayback: true),
                                    )
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
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
                      )),
                      const SizedBox(height: 12),
                    ])))));
  }

  void _initializer() async {
    _recorderController = RecorderController();
    // 내부저장소 경로 로드
    docsDir = await getApplicationDocumentsDirectory();
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

  _setStoragePathWithWord(String word) {
    _fl.storagePath = '${docsDir.path}/recorded_files/$word';
    setState(() {
      _fl.fileList = _fl.loadFiles();
      _setPathForRecord();
    });
  }

  _setPathForRecord() {
    _filePathForRecord =
        '${_fl.storagePath}/음성샘플 ${_fl.fileList.length + 1}.wav';
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
                  if (_isRecording) {
                    _displayMsg("녹음 중에는 재생이 불가능합니다.");
                  } else {
                    _startPlaying(i);
                  }
                },
                icon: Image.asset("assets/images/training_iv_play.png")),
            IconButton(
                onPressed: () {
                  if (_isRecording) {
                    _displayMsg("녹음 중에는 삭제가 불가능합니다.");
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

  Future<void> _startPlaying(i) async {
    setState(() {
      _isPlaying = true;
      _fl.selectedFile = _fl.fileList[i];
    });
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

  void _deleteFile(i) {
    setState(() {
      _fl.selectedFile = _fl.fileList[i];
    });
    _fl.deleteFile("${_fl.storagePath}/${_fl.selectedFile}");
    setState(() {
      _fl.fileList = _fl.loadFiles();
      _setPathForRecord();
    });
  }

  Future<bool> _onBack() async {
    if (_isRecording) {
      _displayMsg("녹음 중에는 이동이 불가능합니다.");
      return false;
    } else if (_isPlaying) {
      _stopPlaying();
      _displayMsg("음성 재생이 중지되었습니다.");
      return true;
    } else {
      return true;
    }
  }

  void _displayMsg(text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color(0xff999999),
        textColor: const Color(0xfffefefe),
        fontSize: 16.0);
  }

  @override
  void dispose() {
    _recorderController.dispose();
    dropDownTextController.dispose();
    super.dispose();
  }
}
