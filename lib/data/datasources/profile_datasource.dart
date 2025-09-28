import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/domain/entities/profile_entity.dart';

class FirebaseProfileDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = "profiles";

  Future<void> saveProfile(Profile profile, String userId) async {
    final profileRef = firestore.collection(collectionName).doc(userId);
    final profileData = profile.toJson();

    // 트랜잭션을 사용하여 원자적(atomic)으로 작업을 처리합니다.
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(profileRef);

      if (!snapshot.exists) {
        // 문서가 존재하지 않으면 (신규 사용자)
        // mission_count를 0으로 설정하여 문서를 생성합니다.
        transaction.set(profileRef, {
          ...profileData,
          'mission_count': 0,
        });
      } else {
        // 문서가 이미 존재하면 (기존 사용자)
        // mission_count를 제외한 나머지 정보만 업데이트합니다.
        transaction.update(profileRef, profileData);
      }
    });
  }

  Future<Profile?> loadProfile(String userId) async {
    final doc = await firestore.collection(collectionName).doc(userId).get();
    if (!doc.exists) return null;
    return Profile.fromJson(doc.data()!);
  }
}
