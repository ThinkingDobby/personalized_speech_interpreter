class DecodingMessage {
  static decodingMsg(List<int> data) {
    // utf8.decode(data.sublist(0, 1));
    if (data[0] == '['.codeUnits[0]) {
      print("메시지로 시작");
    } else {
      print("메시지 시작이 아님");
      return 0;
    }

    try {
      print(data[data[2] - 1]);
      if (data[data[2] - 1] == ']'.codeUnits[0]) {
        print("메시지 끝 맞음");
      } else {
        print("메시지 끝이 아님");
        return 0;
      }
    } on Exception {
      print("값의 범주를 벗어남");
    }

    if (data[1] == 128) {
      return 128;
    } else {
      print("메시지 번호가 없음");
      return 0;
    }
  }
}