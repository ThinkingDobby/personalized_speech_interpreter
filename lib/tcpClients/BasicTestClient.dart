import 'dart:convert';
import 'dart:io';

class BasicTestClient {
  String _host = "210.93.53.8";

  int _port = 10001;

  static Socket? clntSocket;

  void setServAddr(String host, int port) {
    _host = host;
    _port = port;
  }

  Future<void> sendRequest() async {
    clntSocket = await Socket.connect(_host, _port);
    // print("Connected");
  }

  void sendMessage(String data) async{
    clntSocket!.add(utf8.encode(data));
  }

  void stopClnt() {
    if (clntSocket != null) {
      clntSocket!.close();
    } else {
      print("Socket not exists");
    }
    // print("Disconnected");
  }

  String get host => _host;
  int get port => _port;
}