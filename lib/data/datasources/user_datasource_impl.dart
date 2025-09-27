import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/datasources/user_datasource.dart';

class UserDataSourceImpl implements UserDataSource {
  final FirebaseFirestore _firestore;

  UserDataSourceImpl(this._firestore);

  @override
  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    final profileDoc = await _firestore
        .collection('profiles')
        .doc(userId)
        .get();
    if (!profileDoc.exists) {
      // 프로필이 없는 경우 기본값 반환
      return <String, dynamic>{
        'nickname': '게스트',
        'imageFullUrl': 'assets/images/profile/black.png',
        'mission_count': 0,
      };
    }
    return profileDoc.data()!;
  }

  @override
  Stream<Map<String, dynamic>> fetchUserProfileStream(String userId) {
    return _firestore.collection('profiles').doc(userId).snapshots().map(
      (profileDoc) {
        if (!profileDoc.exists) {
          // 프로필이 없는 경우 기본값 반환
          return <String, dynamic>{
            'nickname': '게스트',
            'imageFullUrl': 'assets/images/profile/black.png',
            'mission_count': 0,
          };
        }
        return profileDoc.data()!;
      },
    );
  }
}
