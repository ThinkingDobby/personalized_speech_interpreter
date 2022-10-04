import 'dart:ui' as ui;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:personalized_speech_interpreter/main.dart';

import '../prefs/UserInfo.dart';

void showLearningDialog(parent, context, recorder) {
  showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          contentPadding: EdgeInsets.zero,
          backgroundColor: const Color(0x00ffffff),
          content: Container(
            width: 296,
            height: 477,
            child: Stack(
              children: [
                Container(
                  height: 477,
                  child: Image.asset("assets/images/learning_iv_background.png", fit: BoxFit.fill,)
                ),
                Column(
                  children: [
                    Container(
                        height: 32,
                        alignment: Alignment.topRight,
                        margin: const EdgeInsets.fromLTRB(0, 16, 16, 0),
                        child: Theme(
                          data: ThemeData(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent
                          ),
                          child: InkWell(
                            child: Image.asset("assets/images/learning_btn_cancel.png"),
                            onTap: () => Navigator.pop(context),
                          ),
                        )
                    ),
                    const SizedBox(height: 16),
                    Container(
                      child: Text(
                        '거실 불 켜',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 22,
                          color: Color(0xff191919),
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ),
                    const SizedBox(height: 44),
                    Container(
                      width: 110,
                      height: 110,
                      child: Image.asset("assets/images/learning_iv_book.png"),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      child: Text(
                        "총 10회의 녹음을 진행합니다.\n버튼을 눌러 녹음을 시작해주세요.",
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          color: Color(0xff191919),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 44),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Text(
                          "0",
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            color: const Color(0xffDB8278),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          '/10',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            color: Color(0xff191919),
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8)
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: 250,
                      child: Row(
                        children: [
                          Container(
                            width: 117,
                            alignment: Alignment.center,
                            child: Stack(
                              children: [
                                // Container(
                                //   width: 101,
                                //   height: 50,
                                //   alignment: Alignment.center,
                                //   child: AudioWaveforms(
                                //     waveStyle: WaveStyle(
                                //       gradient: ui.Gradient.linear(
                                //         const Offset(70, 50),
                                //         Offset(MediaQuery.of(context).size.width / 2, 0),
                                //         [const Color(0xffdc8379), const Color(0xfff5b6ae)],
                                //       ),
                                //       showMiddleLine: false,
                                //       extendWaveform: true,
                                //     ),
                                //     enableGesture: false,
                                //     size: Size(MediaQuery.of(context).size.width, 40.0),
                                //     recorderController: _br.recorderController,
                                //   ),
                                // ),
                                Container(
                                  width: 101,
                                  height: 50,
                                  child: Image.asset("assets/images/learning_iv_panel_signal.png"),
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: 125,
                            alignment: Alignment.center,
                            child: Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                                  child: Image.asset("assets/images/learning_iv_panel_record.png"),
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(12, 9, 0, 0),
                                  width: 52,
                                  height: 52,
                                  child: Image.asset("assets/images/training_btn_record.png"),
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(64, 9, 0, 0),
                                  width: 52,
                                  height: 52,
                                  child: Image.asset("assets/images/training_btn_stop_pressed.png"),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            )
          )
          // actions: <Widget>[
          //   FlatButton(
          //     splashColor: Colors.transparent,
          //     highlightColor: Colors.transparent,
          //     child: const Text(
          //         "확인",
          //       style: TextStyle(
          //         color: Color(0xffDB8278),
          //         fontFamily: 'Pretendard',
          //         fontSize: 16,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //     onPressed: () async {
          //       if (userNameController.text.isEmpty) {
          //         Fluttertoast.showToast(
          //             msg: "이름을 한 글자 이상 입력하세요.",
          //             toastLength: Toast.LENGTH_SHORT,
          //             gravity: ToastGravity.CENTER,
          //             timeInSecForIosWeb: 1,
          //             backgroundColor: const Color(0xff999999),
          //             textColor: const Color(0xfffefefe),
          //             fontSize: 16.0);
          //       } else if (userNameController.text.length > 7) {
          //         Fluttertoast.showToast(
          //             msg: "일곱 글자가 넘는 이름은 입력할 수 없습니다.",
          //             toastLength: Toast.LENGTH_SHORT,
          //             gravity: ToastGravity.CENTER,
          //             timeInSecForIosWeb: 1,
          //             backgroundColor: const Color(0xff999999),
          //             textColor: const Color(0xfffefefe),
          //             fontSize: 16.0);
          //       } else {
          //         // 키보드 내리기
          //         FocusManager.instance.primaryFocus?.unfocus();
          //
          //         UserInfo _user = UserInfo();
          //         await _user.setPrefs();
          //         await _user.setUserInfo(userNameController.text);
          //         print("username:" + userNameController.text);
          //
          //         Navigator.pop(context);
          //         Navigator.pop(parent);
          //         Navigator.pushNamed(context, MAIN_PAGE);
          //       }
          //     },
          //   ),
          // ],
        );
      });
}
