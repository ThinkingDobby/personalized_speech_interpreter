import 'package:flutter/material.dart';
import 'package:personalized_speech_interpreter/main_page.dart';

void main() => runApp(PSI());

const String ROOT_PAGE = '/';

class PSI extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TCP Client Test',
        debugShowCheckedModeBanner: false,
        initialRoute: ROOT_PAGE,
        routes: {
          ROOT_PAGE: (context) => main_page()
        }
    );
  }
}