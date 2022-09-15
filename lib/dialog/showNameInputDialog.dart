import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:personalized_speech_interpreter/main.dart';

import '../user/UserInfo.dart';

void showNameInputDialog(parent, context) {
  var userNameController = TextEditingController();

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
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                width: 232,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/dialog_iv_input_background.png")
                  )
                ),
                child: TextFormField(
                  decoration: const InputDecoration.collapsed(
                    hintText: '이름을 입력하세요.',
                    hintStyle: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  controller: userNameController,
                  style: const TextStyle(
                    color: Color(0xff191919),
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: const Text(
                  "확인",
                style: TextStyle(
                  color: Color(0xffDB8278),
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () async {
                if (userNameController.text.isEmpty) {
                  Fluttertoast.showToast(
                      msg: "이름을 한 글자 이상 입력하세요.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: const Color(0xff999999),
                      textColor: const Color(0xfffefefe),
                      fontSize: 16.0);
                } else if (userNameController.text.length > 7) {
                  Fluttertoast.showToast(
                      msg: "일곱 글자가 넘는 이름은 입력할 수 없습니다.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: const Color(0xff999999),
                      textColor: const Color(0xfffefefe),
                      fontSize: 16.0);
                } else {
                  // 키보드 내리기
                  FocusManager.instance.primaryFocus?.unfocus();

                  UserInfo _user = UserInfo();
                  await _user.setPrefs();
                  await _user.setUserInfo(userNameController.text);
                  print("username:" + userNameController.text);

                  Navigator.pop(context);
                  Navigator.pop(parent);
                  Navigator.pushNamed(context, MAIN_PAGE);
                }
              },
            ),
          ],
        );
      });
}
