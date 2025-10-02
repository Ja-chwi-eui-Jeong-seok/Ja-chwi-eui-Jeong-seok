import 'package:ja_chwi/domain/entities/profile_entity.dart';
import 'package:ja_chwi/data/repositories/profile_repository_impl.dart';

class LoadProfileUseCase {
  final ProfileRepositoryImpl repository;

  LoadProfileUseCase(this.repository);

  Future<Profile?> call(String userId) async {
    return await repository.loadProfile(userId);
  }
}