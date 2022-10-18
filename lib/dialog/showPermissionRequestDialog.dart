import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> showPermissionRequestDialog(context, int i) async {
  List<String> messages = [
    "마이크 권한이 필요합니다.",
    "파일 및 미디어 권한이 필요합니다.",
    "마이크, 파일 및 미디어 권한이 필요합니다."
  ];

  await showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 8),
              const Text("권한 없음",
                style: TextStyle(
                  color: Color(0xff191919),
                  fontFamily: 'Pretendard',
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),),
              const SizedBox(height: 16),
              Text(
                messages[i],
                style: const TextStyle(
                  color: Color(0xff676767),
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),),
            ],
          ),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: const Text(
                  "설정으로 이동",
                  style: TextStyle(
                    color: Color(0xffDB8278),
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  openAppSettings();
                },
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
                  onTap: () async {
                    Navigator.pop(context);
                  },
                ),
            )
          ],
        );
      });
}
