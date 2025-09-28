import 'package:ja_chwi/domain/repositories/user_repository.dart';

class FetchUserProfileUseCase {
  final UserRepository repository;

  FetchUserProfileUseCase(this.repository);

  Stream<Map<String, dynamic>> execute(String userId) {
    return repository.fetchUserProfileStream(userId);
  }
}
