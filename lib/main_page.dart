import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';

class MainPage extends StatefulWidget {
  @override
  State createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isRecording = false;
  bool _isNotRecording = true;

  String time = "00:00";
  String message = "거실 불 켜";

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
                          Scaffold.of(context).openEndDrawer();
                        },
                        child: Image.asset("assets/images/main_btn_null.png"));
                  },
                )),
            Pinned.fromPins(
              Pin(size: 200.0, middle: 0.5), Pin(size: 200.0, end: 16.0),
              child: Image.asset("assets/images/main_iv_record_frame.png"),
            ),
            Pinned.fromPins(
                Pin(size: 200, middle: 0.5), Pin(size: 200.0, end: 16.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget> [
                    Container(
                      width: 100,
                      height:100,
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 16),
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
                        margin: EdgeInsets.fromLTRB(113, 96, 0, 0),
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
                  time,
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
                  message,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    color: Color(0xff000000),
                  ),
                  softWrap: false,
                ),
              ),
            ),
          ],
        ),
      ),
      endDrawer: Drawer(child: ListView()),
      endDrawerEnableOpenDragGesture: false,
    );
  }

  Future<void> _startRecording() async {
    // print("start recording");
    // // print("filePathForRecording: ${_filePathForRecord}");
    // Directory directory = Directory(dirname(_filePathForRecord));
    // if (!directory.existsSync()) {
    //   directory.createSync();
    // }
    // _recordingSession.openAudioSession();
    // // 녹음 시작
    // await _recordingSession.startRecorder(
    //   toFile: _filePathForRecord,
    //   codec: Codec.pcm16WAV,
    //   sampleRate: 32000,  // 테스트 위한 조정
    // );
  }

  Future<String?> _stopRecording() async {
    // print("stop recording");
    //   // 녹음 중지
    //   _recordingSession.closeAudioSession();
    //
    //   setState(() {
    //     // 파일 리스트 갱신
    //     _fl.fileList = _fl.loadFiles();
    //     _setPathForRecord();
    //     if (_fl.fileList.length == 1) {
    //       _fl.selectedFile = _fl.fileList[0];
    //     }
    //   });
    //   return await _recordingSession.stopRecorder();
  }
}
