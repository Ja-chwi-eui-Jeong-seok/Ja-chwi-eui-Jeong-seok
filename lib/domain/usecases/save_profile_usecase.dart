import 'package:ja_chwi/domain/entities/profile_entity.dart';
import '../../data/repositories/profile_repository_impl.dart';

class SaveProfileUseCase {
  final ProfileRepositoryImpl repository;

  SaveProfileUseCase(this.repository);

  Future<void> call(Profile profile, String userId) async {
    await repository.saveProfile(profile, userId);
  }
}