import 'package:flutter_riverpod/flutter_riverpod.dart';

//테스트용입니다.
/// 1) 현재 로그인 중인 유저 uid (더미)
final currentUidProvider = Provider<String?>((ref) {
  // TODO: 실제 구현에선 FirebaseAuth.instance.currentUser?.uid
  return 'dummy-uid-123';
});

/// 2) 유저 프로필 더미
class UserProfile {
  final String uid;
  final String nickname;
  final String? profileUrl;
  UserProfile({required this.uid, required this.nickname, this.profileUrl});
}

final userProfileProvider = FutureProvider.family<UserProfile, String>((
  ref,
  uid,
) async {
  // TODO: 실제 구현에선 Firestore 'user profile' 문서 조회
  await Future.delayed(const Duration(milliseconds: 300));
  return UserProfile(uid: uid, nickname: '더미닉네임', profileUrl: null);
});

/// 3) 유저 GPS 더미
class UserGps {
  final String uid;
  final String location; // 동명
  final double lat;
  final double lng;
  UserGps({
    required this.uid,
    required this.location,
    required this.lat,
    required this.lng,
  });
}

final userGpsProvider = FutureProvider.family<UserGps, String>((
  ref,
  uid,
) async {
  // TODO: 실제 구현에선 Firestore 'User GPS' 문서 조회 (gps_delete_yn=false 등 조건)
  await Future.delayed(const Duration(milliseconds: 300));
  return UserGps(uid: uid, location: '동작구', lat: 37.5, lng: 127.0);
});
