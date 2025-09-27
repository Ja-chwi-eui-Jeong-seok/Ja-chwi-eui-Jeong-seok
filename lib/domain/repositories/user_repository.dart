abstract class UserRepository {
  /// 사용자의 프로필 정보를 가져옵니다.
  Future<Map<String, dynamic>> fetchUserProfile(String userId);

  /// 사용자의 프로필 정보를 실시간으로 가져옵니다.
  Stream<Map<String, dynamic>> fetchUserProfileStream(String userId);
}
