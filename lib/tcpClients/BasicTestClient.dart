import 'dart:convert';
import 'dart:io';

class BasicTestClient {
  String _host = "192.168.35.243";
  // String _host = "192.168.26.33";  // x1 - hotspot
  // String _host = "192.168.35.25"; // mac

  int _port = 10001;

  static late Socket clntSocket;

  void setServAddr(String host, int port) {
    _host = host;
    _port = port;
  }

  Future<void> sendRequest() async {
    clntSocket = await Socket.connect(_host, _port);
    // print("Connected");
  }

  void sendMessage(String data) async{
    clntSocket.add(utf8.encode(data));
  }

  void stopClnt() {
    clntSocket.close();
    // print("Disconnected");
  }

  String get host => _host;
  int get port => _port;
}