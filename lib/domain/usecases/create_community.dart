import 'package:ja_chwi/domain/entities/community.dart';
import 'package:ja_chwi/domain/repositories/community_repository.dart';

class CreateCommunity {
  final CommunityRepository repo;
  CreateCommunity(this.repo);

  Future<String> call(Community input) {
    return repo.create(input);
  }
}
