import 'dart:io';

import 'package:flutter/material.dart';

import 'dialog/showNameInputDialog.dart';

class InitPage extends StatefulWidget {
  @override
  State createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  ValueNotifier<int> dialogTrigger = ValueNotifier(0);
  bool _first = true;
  bool _dialogShown = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: dialogTrigger,
        builder: (ctx, value, child) {
          if (_first) {
            Future.delayed(const Duration(seconds: 0), () async {
              await showNameInputDialog(context, ctx);
              _first = false;
              setState(() {
                _dialogShown = false;
              });
            });
          }
          return GestureDetector(
            onTap: () async {
              showNameInputDialog(context, ctx);
              setState(() {
                _dialogShown = false;
              });
            },
            child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xffffffff), Color(0xfff2f2f2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
                child: Container(
                    alignment: Alignment.center,
                    child: Wrap(
                      children: [
                        Visibility(
                            visible: !_dialogShown,
                            child: Column(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  child: Image.asset("assets/images/loading_iv_splash.png"),
                                ),
                                const SizedBox(height: 32),
                                Container(
                                  child: const Text("앱을 시작하려면 사용자를 등록해야 합니다.\n화면을 터치해 사용자를 등록하세요.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xff676767),
                                      fontFamily: 'Pretendard',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),),
                                )
                              ],
                            )
                        ),
                      ],
                    )
                )
            ),
          );
        },
      ),
    );
  }
}