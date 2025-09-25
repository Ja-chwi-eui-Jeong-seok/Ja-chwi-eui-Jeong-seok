import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/domain/entities/profile_entity.dart';

class FirebaseProfileDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = "profiles";

  Future<void> saveProfile(Profile profile, String userId) async {
    await firestore.collection(collectionName).doc(userId).set(profile.toJson());
  }

  Future<Profile?> loadProfile(String userId) async {
    final doc = await firestore.collection(collectionName).doc(userId).get();
    if (!doc.exists) return null;
    return Profile.fromJson(doc.data()!);
  }
}