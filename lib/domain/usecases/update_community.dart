import 'package:ja_chwi/domain/repositories/community_repository.dart';

class UpdateCommunity {
  final CommunityRepository repo;
  UpdateCommunity(this.repo);

  Future<void> call({
    required String id, // doc.id
    required Map<String, dynamic> patch,
  }) {
    return repo.update(id, patch);
  }
}
