import 'package:ja_chwi/domain/entities/block_entity.dart';

class BlockModel {
  final String id;
  final String userId;
  final String blockedBy;
  final String? reason;
  final DateTime createdAt;

  BlockModel({
    required this.id,
    required this.userId,
    required this.blockedBy,
    this.reason,
    required this.createdAt,
  });

  BlockEntity toDomain() => BlockEntity(
        id: id,
        userId: userId,
        blockedBy: blockedBy,
        reason: reason,
        createdAt: createdAt,
      );

  factory BlockModel.fromDomain(BlockEntity entity) => BlockModel(
        id: entity.id,
        userId: entity.userId,
        blockedBy: entity.blockedBy,
        reason: entity.reason,
        createdAt: entity.createdAt,
      );
}
