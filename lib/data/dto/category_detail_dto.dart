import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryDetailDto {
  final int categorycode;
  final int categorydetailcode;
  final String categorydetailname;
  final Timestamp categorycreate;
  final Timestamp? categoryupdate;
  final Timestamp? categorydelete;
  final bool categorydeleteyn;
  final String? categorydeletenote;

  CategoryDetailDto({
    required this.categorycode,
    required this.categorydetailcode,
    required this.categorydetailname,
    required this.categorycreate,
    this.categoryupdate,
    this.categorydelete,
    required this.categorydeleteyn,
    this.categorydeletenote,
  });

  factory CategoryDetailDto.fromFirebase(Map<String, dynamic> data) {
    return CategoryDetailDto(
      categorycode: data['category_code'],
      categorydetailcode: data['category_detail_code'],
      categorydetailname: data['category_detail_name'],
      categorycreate: data['category_create'],
      categoryupdate: data['category_update'] as Timestamp?,
      categorydelete: data['category_delete'] as Timestamp?,
      categorydeleteyn: data['category_delete_yn'],
      categorydeletenote: data['category_delete_note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category_code': categorycode,
      'category_detail_code': categorydetailcode,
      'category_detail_name': categorydetailname,
      'category_create': categorycreate,
      'category_update': categoryupdate,
      'category_delete': categorydelete,
      'category_delete_yn': categorydeleteyn,
      'category_delete_note': categorydeletenote,
    };
  }
}
