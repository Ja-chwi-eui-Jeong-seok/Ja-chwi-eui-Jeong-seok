import 'package:cloud_firestore/cloud_firestore.dart';

//parant카테코리
class CategoryCodeDto {
  final int code;
  final String name;
  final Timestamp createAt;
  final Timestamp? updateAt;
  final Timestamp? deletedAt;
  final bool delete;
  final String? deleteNote;

  CategoryCodeDto({
    required this.code,
    required this.name,
    required this.createAt,
    this.updateAt,
    this.deletedAt,
    required this.delete,
    this.deleteNote,
  });

  factory CategoryCodeDto.fromFirebase(Map<String, dynamic> data) {
    return CategoryCodeDto(
      code: data['code'],
      name: data['name'],
      createAt: data['createAt'],
      updateAt: data['updateAt'] as Timestamp?,
      deletedAt: data['deletedAt'] as Timestamp?,
      delete: data['delete'],
      deleteNote: data['deleteNode'] as String?,
    );
  }

  //업데이트,삭제
  CategoryCodeDto copyWithFirebase(Map<String, dynamic> data) {
    return CategoryCodeDto(
      code: data['code'] as int? ?? code,
      name: data['name'] as String? ?? name,
      createAt: data['createAt'] as Timestamp? ?? createAt,
      updateAt: data['updateAt'] as Timestamp? ?? updateAt,
      deletedAt: data['deletedAt'] as Timestamp? ?? deletedAt,
      delete: data['delete'] as bool? ?? delete,
      deleteNote: data['deleteNote'] as String? ?? deleteNote,
    );
  }
}
