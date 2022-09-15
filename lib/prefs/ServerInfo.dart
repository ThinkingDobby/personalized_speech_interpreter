import 'package:personalized_speech_interpreter/tcpClients/BasicTestClient.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerInfo {
  late SharedPreferences servPrefs;

  String? servIPAddr;
  String? servPort;

  setPrefs() async {
    servPrefs = await SharedPreferences.getInstance();
  }

  loadServerInfo() {
    servIPAddr = servPrefs.getString("servIPAddr") ?? BasicTestClient().host;
    servPort = servPrefs.getString("servPort") ?? BasicTestClient().port.toString();
  }

  setServerInfo(String servIpAddr, String servPort) async {
    await servPrefs.setString("servIPAddr", servIpAddr);
    await servPrefs.setString("servPort", servPort);
  }
}