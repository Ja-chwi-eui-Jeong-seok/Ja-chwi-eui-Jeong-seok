import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/domain/entities/profile_entity.dart';

class FirebaseProfileDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = "profiles";

  Future<void> saveProfile(Profile profile, String userId) async {
    final profileData = profile.toJson();
    profileData['mission_count'] = 0; // mission_count 필드 추가 및 초기화
    await firestore.collection(collectionName).doc(userId).set(profileData);
  }

  Future<Profile?> loadProfile(String userId) async {
    final doc = await firestore.collection(collectionName).doc(userId).get();
    if (!doc.exists) return null;
    return Profile.fromJson(doc.data()!);
  }
}
