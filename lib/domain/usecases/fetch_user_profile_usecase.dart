import 'package:firebase_auth/firebase_auth.dart';
import 'package:ja_chwi/domain/repositories/user_repository.dart';

class FetchUserProfileUseCase {
  final UserRepository repository;

  FetchUserProfileUseCase(this.repository);

  Stream<Map<String, dynamic>> execute([String? uid]) {
    final userId = uid ?? FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      // 로그인하지 않았거나 uid가 제공되지 않은 경우 예외 처리
      throw Exception('User ID is not available.');
    }
    return repository.fetchUserProfileStream(userId);
  }
}
