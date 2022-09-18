import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart';

class FileLoader {
  //  저장소 경로
  late String storagePath;

  // 재생 위해 선택된 파일
  String selectedFile = '-1';

  // 파일 이름 저장할 리스트
  List<String> fileList = <String>[];
  int lastNum = 0;

  List<String> loadFiles() {
    List<String> files = <String>[];

    Directory directory = Directory(storagePath);
    if (!directory.existsSync()) {
      directory.createSync();
    }
    var dir = Directory(storagePath).listSync();

    int check = 0;
    for (var file in dir) {
      // 확장자 검사
      String fileName = getFilenameFromPath(file.path);

      if (checkExtWav(file.path)) {
        files.add(fileName);

        check = max(check, getFileNumber(fileName));
      }
    }
    lastNum = check;

    files.sort((a, b) => getFileNumber(a).compareTo(getFileNumber(b)));

    return files;
  }

  bool checkExtWav(String fileName) {
    if (fileName.substring(fileName.length - 3) == "wav") {
      return true;
    } else {
      return false;
    }
  }

  String getFilenameFromPath(String filePath) {
    int idx = filePath.lastIndexOf('/') + 1;
    return filePath.substring(idx);
  }

  int getFileNumber(String fileName) {
    String num = fileName.substring(5, fileName.length - 4);

    return int.parse(num);
  }

  deleteFile(String filePath) {
    File(filePath).delete();
  }

  deleteFiles() {
    var dir = Directory(storagePath).listSync();
    for (var file in dir) {
      if (checkExtWav(file.path)) {
        file.delete();
      }
    }
  }

  Future<Uint8List> readFile(String filePath) async {
    print(filePath);
    Uint8List data = File(filePath).readAsBytesSync();
    return data;
  }
}