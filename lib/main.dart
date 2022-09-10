import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:personalized_speech_interpreter/InitPage.dart';
import 'package:personalized_speech_interpreter/user/UserInfo.dart';

import 'MainPage.dart';
import 'TestPage.dart';
import 'TrainingPage.dart';

void main() async {
  // 상태바, 내비게이션바 색상 조정
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: const Color(0xffffffff),
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: const Color(0xfff2f2f2),
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarBrightness: Platform.isIOS ? Brightness.light : Brightness.dark,
  ));

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  UserInfo _user = UserInfo();
  await _user.setPrefs();
  bool _userReady = _user.loadUserInfo();

  runApp(PSI(_userReady));
  Timer.periodic(const Duration(milliseconds: 1000), (timer) {
    FlutterNativeSplash.remove();
  });
}

const String MAIN_PAGE = '/main';
const String INIT_PAGE = '/init';
const String TEST_PAGE = '/test';
const String TRAINING_PAGE = '/training';

class PSI extends StatelessWidget {
  final bool _userReady;
  PSI(this._userReady);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TCP Client Test',
        debugShowCheckedModeBanner: false,
        initialRoute: _userReady ? MAIN_PAGE : INIT_PAGE,
        routes: {
          MAIN_PAGE: (context) => MainPage(),
          INIT_PAGE: (context) => InitPage(),
          TEST_PAGE: (context) => TestPage(),
          TRAINING_PAGE: (context) => TrainingPage()
        });
  }
}
