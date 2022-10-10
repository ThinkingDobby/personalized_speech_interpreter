import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../file/FileLoader.dart';

Future<bool> showLearningResetDialog(context, target) async {
  final _fl = FileLoader();
  List<String> _trainedWords = [];
  late SharedPreferences _wordPrefs;

  _wordPrefs = await SharedPreferences.getInstance();
  _trainedWords = _wordPrefs.getStringList("trainedWords") ?? [];

  var docsDir = await getApplicationDocumentsDirectory();
  _fl.storagePath = '${docsDir.path}/recorded_files/$target';

  bool flag = true;

  await showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("이미 학습된 단어입니다.",
                style: TextStyle(
                  color: Color(0xff191919),
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),),
              Text("초기화 하시겠습니까?",
                style: TextStyle(
                  color: Color(0xffDB8278),
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),)
            ],
          ),
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: InkWell(
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
                  onTap: () async {
                    _fl.deleteFiles();

                    _trainedWords.remove(target);
                    await _wordPrefs.setStringList("trainedWords", _trainedWords);

                    flag = true;
                    Navigator.pop(context);
                  }
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
              child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: const Text(
                    "취소",
                    style: TextStyle(
                      color: Color(0xff191919),
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    flag = false;
                    Navigator.pop(context);
                  })
            )
          ],
        );
      });

  return flag;
}

