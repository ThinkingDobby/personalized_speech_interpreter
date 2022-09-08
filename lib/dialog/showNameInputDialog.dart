import 'package:flutter/material.dart';
import 'package:personalized_speech_interpreter/main.dart';

void showNameInputDialog(parent, context) {
  showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Text("사용자 등록",
                style: TextStyle(
                  color: Color(0xff191919),
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),),
            ],
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Text(
                "앱 내에서 사용될 이름을 입력하세요.",
                style: TextStyle(
                  color: Color(0xff191919),
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                  "확인",
                style: TextStyle(
                  color: Color(0xffDB8278),
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(parent);
              },
            ),
          ],
        );
      });
}
