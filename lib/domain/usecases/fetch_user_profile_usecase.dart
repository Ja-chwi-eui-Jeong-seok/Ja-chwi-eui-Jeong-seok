import 'package:firebase_auth/firebase_auth.dart';
import 'package:ja_chwi/domain/repositories/mission_repository.dart';

class FetchUserProfileUseCase {
  final MissionRepository repository;

  FetchUserProfileUseCase(this.repository);

  Stream<Map<String, dynamic>> execute() {
    return repository.fetchUserProfileStream(
      FirebaseAuth.instance.currentUser!.uid,
    );
  }
}
