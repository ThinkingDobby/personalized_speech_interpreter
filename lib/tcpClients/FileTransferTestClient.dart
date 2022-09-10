import 'dart:typed_data';

import 'package:fftea/impl.dart';

import '../util/util.dart';
import 'BasicTestClient.dart';

class FileTransferTestClient extends BasicTestClient {
  void sendFile(int type, Uint8List data) async {
    switch (type) {
      case 1: // wav파일 전송
        Uint8List header = Uint8List.fromList(
            [type] + Util.convertInt2Bytes(data.length, Endian.big, 4));
        clntSocket.add(header + data);
        stopClnt();
        break;
      case 2: // pcm파일 실시간 전송
        Uint8List header = Uint8List.fromList(
            [type] + Util.convertInt2Bytes(data.length, Endian.big, 4));
        clntSocket.add(header + data);
        stopClnt();
        break;
      case 3: // 식별정보(이름) 전송
        break;
    }
  }
}