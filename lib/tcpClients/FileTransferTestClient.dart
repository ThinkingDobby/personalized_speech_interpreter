import 'dart:typed_data';

import 'package:fftea/impl.dart';

import '../util/util.dart';
import 'BasicTestClient.dart';

class FileTransferTestClient extends BasicTestClient {
  void sendFile(int type, Uint8List data) async {
    if (type == 1 || type == 2) {
      Uint8List header = Uint8List.fromList(
          [type] + Util.convertInt2Bytes(data.length, Endian.big, 4));
      clntSocket.add(header + data);
      stopClnt();
    }
  }
}