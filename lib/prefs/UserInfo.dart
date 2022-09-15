import 'package:shared_preferences/shared_preferences.dart';

class UserInfo {
  late SharedPreferences userPrefs;

  String? userName;

  setPrefs() async {
    userPrefs = await SharedPreferences.getInstance();
  }

  bool loadUserInfo(){
    userName = userPrefs.getString("userName");

    return userName != null;
  }

  setUserInfo(String userName) async {
    await userPrefs.setString("userName", userName);
  }
}