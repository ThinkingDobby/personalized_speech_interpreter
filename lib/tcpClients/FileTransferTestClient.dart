import 'dart:convert';
import 'dart:typed_data';

import '../utils/TypeConverter.dart';
import 'BasicTestClient.dart';

class FileTransferTestClient extends BasicTestClient {
  void sendFile(int type, Uint8List data) async {
    switch (type) {
      case 1: // wav파일 전송
        var start = Uint8List.fromList(utf8.encode("["));
        var typ = Uint8List.fromList([type]);
        var msgSize = Uint8List.fromList([11]);
        var ext = Uint8List.fromList(utf8.encode("wav"));
        var fileSize = Uint8List.fromList(TypeConverter.convertInt2Bytes(data.length, Endian.big, 4));
        var end = Uint8List.fromList(utf8.encode("]"));

        var header = start + typ + msgSize + ext +fileSize;

        clntSocket.add(header + data);
        clntSocket.add(end);
        stopClnt();
        break;
      case 2: // pcm파일 실시간 전송
        Uint8List header = Uint8List.fromList(
            [type] + TypeConverter.convertInt2Bytes(data.length, Endian.big, 4));
        clntSocket.add(header + data);
        stopClnt();
        break;
      case 3: // 식별정보(이름) 전송
        break;
    }
  }
}