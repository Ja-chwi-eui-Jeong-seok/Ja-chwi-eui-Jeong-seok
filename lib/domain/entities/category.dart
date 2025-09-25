import 'package:cloud_firestore/cloud_firestore.dart';

// parent 카테고리
class Category {
  final int categoryCode;
  final String categoryName;
  final Timestamp categoryCreate;
  final Timestamp? categoryUpdate;
  final Timestamp? categoryDelete;
  final bool categoryDeleteYn;
  final String? categoryDeleteNote;

  Category({
    required this.categoryCode,
    required this.categoryName,
    required this.categoryCreate,
    this.categoryUpdate,
    this.categoryDelete,
    required this.categoryDeleteYn,
    this.categoryDeleteNote,
  });

  // Firestore → Entity
  factory Category.fromFirebase(Map<String, dynamic> data) {
    return Category(
      categoryCode: data['category_code'],
      categoryName: data['category_name'],
      categoryCreate: data['category_create'],
      categoryUpdate: data['category_update'] as Timestamp?,
      categoryDelete: data['category_delete'] as Timestamp?,
      categoryDeleteYn: data['category_delete_yn'],
      categoryDeleteNote: data['category_delete_note'] as String?,
    );
  }

  // Firestore 저장용
  Map<String, dynamic> toMap() {
    return {
      'category_code': categoryCode,
      'category_name': categoryName,
      'category_create': categoryCreate,
      'category_update': categoryUpdate,
      'category_delete': categoryDelete,
      'category_delete_yn': categoryDeleteYn,
      'category_delete_note': categoryDeleteNote,
    };
  }
}

// child 카테고리
class CategoryDetail {
  final int categoryCode;
  final int categoryDetailCode;
  final String categoryDetailName;
  final Timestamp categoryCreate;
  final Timestamp? categoryUpdate;
  final Timestamp? categoryDelete;
  final bool categoryDeleteYn;
  final String? categoryDeleteNote;

  CategoryDetail({
    required this.categoryCode,
    required this.categoryDetailCode,
    required this.categoryDetailName,
    required this.categoryCreate,
    this.categoryUpdate,
    this.categoryDelete,
    required this.categoryDeleteYn,
    this.categoryDeleteNote,
  });

  // Firestore → Entity
  factory CategoryDetail.fromFirebase(Map<String, dynamic> data) {
    return CategoryDetail(
      categoryCode: data['category_code'],
      categoryDetailCode: data['category_detail_code'],
      categoryDetailName: data['category_detail_name'],
      categoryCreate: data['category_create'],
      categoryUpdate: data['category_update'] as Timestamp?,
      categoryDelete: data['category_delete'] as Timestamp?,
      categoryDeleteYn: data['category_delete_yn'],
      categoryDeleteNote: data['category_delete_note'] as String?,
    );
  }

  // Firestore 저장용
  Map<String, dynamic> toMap() {
    return {
      'category_code': categoryCode,
      'category_detail_code': categoryDetailCode,
      'category_detail_name': categoryDetailName,
      'category_create': categoryCreate,
      'category_update': categoryUpdate,
      'category_delete': categoryDelete,
      'category_delete_yn': categoryDeleteYn,
      'category_delete_note': categoryDeleteNote,
    };
  }
}
