// domain/usecases/soft_delete_community.dart
import 'package:ja_chwi/domain/repositories/community_repository.dart';

class SoftDeleteCommunity {
  final CommunityRepository repo;
  SoftDeleteCommunity(this.repo);

  Future<void> call(String id, {String? note}) {
    return repo.softDelete(id, note: note);
  }
}
