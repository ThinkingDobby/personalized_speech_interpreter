/*
상태

0: 다일로그 실행
1: 녹음중
2: 전송중
3: 전송 성공
4: 전송 실패
5: 학습 진행 중
6: 학습 완료
 */

List<String> stateImages = [
  "assets/images/learning_iv_book.png",
  "assets/images/learning_iv_signal.png",
  "assets/images/learning_iv_send.png",
  "assets/images/learning_iv_book.png",
  "assets/images/learning_iv_book.png",
  "assets/images/learning_iv_book_sync.png",
  "assets/images/learning_iv_check.png",
];

List<String> stateMessages = [
  "총 10회의 녹음을 진행합니다.\n녹음 버튼을 눌러 녹음을 시작해주세요.",
  "상단의 문장을 따라 읽은 후,\n중지버튼을 눌러주세요.",
  "학습을 위해 음성을 전달중입니다.\n잠시만 기다려주세요.",
  "전달에 성공했습니다.\n다음 녹음을 시작해주세요.",
  "전달에 실패했습니다.\n다시 녹음해주세요.",
  "학습을 진행중입니다.\n잠시만 기다려주세요.",
  "학습이 완료되었습니다!\n이제 번역이 가능합니다."
];