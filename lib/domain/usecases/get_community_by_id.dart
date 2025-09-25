// domain/usecases/get_community_by_id.dart
import 'package:ja_chwi/domain/entities/community.dart';
import 'package:ja_chwi/domain/repositories/community_repository.dart';

class GetCommunityById {
  final CommunityRepository repo;
  GetCommunityById(this.repo);

  Future<Community?> call(String id) => repo.getById(id);
}
