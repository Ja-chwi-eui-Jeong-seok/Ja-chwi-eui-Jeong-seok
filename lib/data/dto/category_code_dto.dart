import 'package:cloud_firestore/cloud_firestore.dart';

//parant카테코리
class CategoryCodeDto {
  final int categorycode;
  final String categoryname;
  final Timestamp categorycreate;
  final Timestamp? categoryupdate;
  final Timestamp? categorydelete;
  final bool categorydeleteyn;
  final String? categorydeletenote;

  CategoryCodeDto({
    required this.categorycode,
    required this.categoryname,
    required this.categorycreate,
    this.categoryupdate,
    this.categorydelete,
    required this.categorydeleteyn,
    this.categorydeletenote,
  });

  factory CategoryCodeDto.fromFirebase(Map<String, dynamic> data) {
    return CategoryCodeDto(
      categorycode: data['category_code'],
      categoryname: data['category_name'],
      categorycreate: data['category_create'],
      categoryupdate: data['category_update'] as Timestamp?,
      categorydelete: data['category_delete'] as Timestamp?,
      categorydeleteyn: data['category_delete_yn'],
      categorydeletenote: data['category_delete_note'] as String?,
    );
  }

  //업데이트,삭제
  CategoryCodeDto copyWithFirebase(Map<String, dynamic> data) {
    return CategoryCodeDto(
      categorycode: data['category_code'] as int? ?? categorycode,
      categoryname: data['category_name'] as String? ?? categoryname,
      categorycreate: data['category_create'] as Timestamp? ?? categorycreate,
      categoryupdate: data['category_update'] as Timestamp? ?? categoryupdate,
      categorydelete: data['category_delete'] as Timestamp? ?? categorydelete,
      categorydeleteyn: data['category_delete_yn'] as bool? ?? categorydeleteyn,
      categorydeletenote:
          data['category_delete_note'] as String? ?? categorydeletenote,
    );
  }
}
