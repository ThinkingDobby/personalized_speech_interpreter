import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'MainPage.dart';
import 'TestPage.dart';
import 'TrainingPage.dart';


void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(PSI());
  Timer.periodic(const Duration(milliseconds: 1000), (timer) { FlutterNativeSplash.remove(); });
}

const String ROOT_PAGE = '/';
const String TEST_PAGE = '/test';
const String TRAINING_PAGE = '/training';

class PSI extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TCP Client Test',
        debugShowCheckedModeBanner: false,
        initialRoute: ROOT_PAGE,
        routes: {
          ROOT_PAGE: (context) => MainPage(),
          TEST_PAGE: (context) => TestPage(),
          TRAINING_PAGE: (context) => TrainingPage()
        }
    );
  }
}