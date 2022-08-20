import 'package:flutter/material.dart';

import 'MainPage.dart';
import 'TestPage.dart';


void main() => runApp(PSI());

const String ROOT_PAGE = '/';
const String TEST_PAGE = '/test';

class PSI extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TCP Client Test',
        debugShowCheckedModeBanner: false,
        initialRoute: ROOT_PAGE,
        routes: {
          ROOT_PAGE: (context) => MainPage(),
          TEST_PAGE: (context) => TestPage()
        }
    );
  }
}