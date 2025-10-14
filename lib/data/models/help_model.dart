import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/domain/entities/help_entity.dart';

class HelpModel extends HelpEntity {
  HelpModel({
    required super.id,
    required super.title,
    required super.content,
    required super.createdBy,
    required super.createdAt,
    required super.updatedBy,
    super.updatedAt,
    super.deletedBy,
    super.deletedAt,
    required super.deleteFlag,
  });

  factory HelpModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HelpModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)!.toDate(),
      updatedBy: data['updatedBy'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      deletedBy: data['deletedBy'],
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      deleteFlag: data['deleteFlag'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "title": title,
      "content": content,
      "createdBy": createdBy,
      "createdAt": createdAt,
      "updatedBy": updatedBy,
      "updatedAt": updatedAt,
      "deletedBy": deletedBy,
      "deletedAt": deletedAt,
      "deleteFlag": deleteFlag,
    };
  }
}
