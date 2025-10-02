import 'package:ja_chwi/domain/entities/profile_entity.dart';
import 'package:ja_chwi/data/datasources/profile_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileRepositoryImpl {
  final FirebaseProfileDataSource dataSource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileRepositoryImpl(this.dataSource);
  

  Future<void> saveProfile(Profile profile, String userId) async {
    await dataSource.saveProfile(profile, userId);
  }

  Future<Profile?> loadProfile(String userId) async {
    return await dataSource.loadProfile(userId);
  }

  /// 닉네임 중복 체크
  Future<bool> isNicknameDuplicate(String nickname) async {
    final querySnapshot = await _firestore
        .collection('profiles')
        .where('nickname', isEqualTo: nickname)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}