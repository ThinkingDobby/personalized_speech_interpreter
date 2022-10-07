import 'dart:convert';
import 'dart:typed_data';

import '../prefs/UserInfo.dart';
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
        var fileSize = Uint8List.fromList(
            TypeConverter.convertInt2Bytes(data.length, Endian.big, 4));
        var end = Uint8List.fromList(utf8.encode("]"));

        var header = start + typ + msgSize + ext + fileSize + end;

        BasicTestClient.clntSocket!.add(header);
        BasicTestClient.clntSocket!.add(data);
        // stopClnt();
        break;
      case 2: // pcm파일 실시간 전송은 우선 TestPage에서 직접 다루도록 구성
        break;
    }
  }
    
  void sendID(int type) async {
    switch (type) {
      case 3:
        var start = Uint8List.fromList(utf8.encode("["));
        var typ = Uint8List.fromList([type]);

        var user = UserInfo();
        await user.setPrefs();
        user.loadUserInfo();
        var name = Uint8List.fromList(utf8.encode(user.userName!));

        var msgLen = name.length;
        var msgSize = Uint8List.fromList([msgLen + 4]);

        var end = Uint8List.fromList(utf8.encode("]"));

        var msg = start + typ + msgSize + name + end;

        BasicTestClient.clntSocket!.add(msg);
        // stopClnt();
        break;
    }
  }

  void sendFileWithInfo(int type, String sentence, int num, Uint8List data) {
    switch (type) {
      case 4:
        var start = Uint8List.fromList(utf8.encode("["));
        var typ = Uint8List.fromList([type]);

        var targetSentence = Uint8List.fromList(utf8.encode(sentence));
        var fileNum = Uint8List.fromList([num]);

        var msgLen = targetSentence.length;
        var msgSize = Uint8List.fromList([msgLen + 12]);

        var ext = Uint8List.fromList(utf8.encode("wav"));
        var fileSize = Uint8List.fromList(
            TypeConverter.convertInt2Bytes(data.length, Endian.big, 4));
        var end = Uint8List.fromList(utf8.encode("]"));

        var header = start + typ + msgSize + targetSentence + fileNum + ext + fileSize + end;
        print(header);
        print(msgSize);
        print(targetSentence);
        print(header.length);

        BasicTestClient.clntSocket!.add(header);
        BasicTestClient.clntSocket!.add(data);

        break;
    }
  }
}