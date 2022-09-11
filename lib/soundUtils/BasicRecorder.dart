import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class BasicRecorder {
  bool isRecording = false;
  bool isNotRecording = true;

  // 녹음 위한 객체 저장
  late FlutterSoundRecorder recordingSession;

  // 음성 신호 시각화 위한 객체 저장
  final RecorderController recorderController = RecorderController();

  init() async {
    // 권한 요청
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  setRecordingSession() async {
    // 객체 설정
    recordingSession = FlutterSoundRecorder();
    await recordingSession.openAudioSession(
        focus: AudioFocus.requestFocusAndStopOthers,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);
    await recordingSession
        .setSubscriptionDuration(const Duration(milliseconds: 10));
    await initializeDateFormatting();
  }

  Future<void> startRecording(String path) async {
    // print("start recording");
    // print("filePathForRecording: ${_filePathForRecord}");
    Directory directory = Directory(dirname(path));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    recordingSession.openAudioSession();
    // 녹음 시작
    await recordingSession.startRecorder(
      toFile: path,
      codec: Codec.pcm16WAV,
    );

    await recorderController.record(); // 경로 임시 제거 - 기본 경로: git log 참고
  }

  Future<void> stopRecording() async {
    // print("stop recording");
    // 녹음 중지
    recordingSession.closeAudioSession();
    await recorderController.pause();
    await recordingSession.stopRecorder();
  }
}