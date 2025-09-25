class TutorialEntity {
  final String accountData; //계정 정보
  final bool tutorialCheckUp; //튜토리얼 y/n
  final DateTime tutorialCreateDate; //튜토리얼 실행날짜

  TutorialEntity({
    required this.accountData,
    required this.tutorialCheckUp,
    required this.tutorialCreateDate,
  });
}
