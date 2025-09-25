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
      categorycode: data['categorycode'],
      categorydetailcode: data['categorydetailcode'],
      categorydetailname: data['categorydetailname'],
      categorycreate: data['categorycreate'],
      categoryupdate: data['categoryupdate'] as Timestamp?,
      categorydelete: data['categorydelete'] as Timestamp?,
      categorydeleteyn: data['categorydeleteyn'],
      categorydeletenote: data['categorydeletenote'] as String?,
    );
  }
}
