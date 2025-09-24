class AuthEntity {
  final String id; //있어야 할 것 같아서 넣음
  final String accountData; //계정정보
  final String accountEmail; //이메일 정보
  final String accountType; // google/apple
  final String createDevice; // 기종
  final bool privacyConsent; //개인정보동의여부
  final bool agreeToTermsOfService; //약관동의
  final DateTime? userCreateDate; //인증받은날짜
  final DateTime? userUpdateDate; //프로파일 수정일자
  final DateTime? userDeleteDate; //삭제일자
  final String userDeleteNote; //삭제사유
  final bool managerType; //관리자 타입

  AuthEntity({
    required this.id,
    required this.accountData,
    required this.accountEmail,
    required this.accountType,
    required this.createDevice,
    required this.privacyConsent,
    required this.agreeToTermsOfService,
    required this.userCreateDate,
    required this.userUpdateDate,
    required this.userDeleteDate,
    required this.userDeleteNote,
    required this.managerType,
  });
}
