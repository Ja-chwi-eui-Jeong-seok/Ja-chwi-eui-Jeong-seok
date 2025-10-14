class HelpEntity {
  final String id;
  final String title;
  final String content;
  final String createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;
  final String? deletedBy;
  final DateTime? deletedAt;
  final bool deleteFlag;

  HelpEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.deletedBy,
    this.deletedAt,
    this.deleteFlag = false,
  });

  HelpEntity copyWith({
    String? title,
    String? content,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return HelpEntity(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedBy: deletedBy,
      deletedAt: deletedAt,
      deleteFlag: deleteFlag,
    );
  }
}
