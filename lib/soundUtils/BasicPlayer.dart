import 'package:assets_audio_player/assets_audio_player.dart';

class BasicPlayer {
  bool isPlaying = false;

  // 재생 위한 객체 저장
  final audioPlayer = AssetsAudioPlayer();

  Future<void> startPlaying(String path) async {
    // 재생
    audioPlayer.open(
      Audio.file(path),
      autoStart: true,
      showNotification: true,
    );
    // print("filePathForPlaying ${_fl.storagePath}/${_fl.selectedFile}");
    audioPlayer.playlistAudioFinished.listen((event) {
      isPlaying = false;
    });
  }

  Future<void> stopPlaying() async {
    // 재생 중지
    audioPlayer.stop();
  }
}