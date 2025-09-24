import 'package:cloud_firestore/cloud_firestore.dart';

//parant카테코리
class Category {
  final int categorycode;
  final String categoryname;
  final Timestamp categorycreate;
  final Timestamp? categoryupdate;
  final Timestamp? categorydelete;
  final bool categorydeleteyn;
  final String? categorydeletenote;

  Category({
    required this.categorycode,
    required this.categoryname,
    required this.categorycreate,
    this.categoryupdate,
    this.categorydelete,
    required this.categorydeleteyn,
    this.categorydeletenote,
  });

  factory Category.fromFirebase(Map<String, dynamic> data) {
    return Category(
      categorycode: data['categorycode'],
      categoryname: data['categoryname'],
      categorycreate: data['categorycreate'],
      categoryupdate: data['categoryupdate'] as Timestamp?,
      categorydelete: data['categorydelete'] as Timestamp?,
      categorydeleteyn: data['categorydeleteyn'],
      categorydeletenote: data['categorydeletenote'] as String?,
    );
  }

  //업데이트,삭제
  Category copyWithFirebase(Map<String, dynamic> data) {
    return Category(
      categorycode: data['code'] as int? ?? categorycode,
      categoryname: data['name'] as String? ?? categoryname,
      categorycreate: data['createAt'] as Timestamp? ?? categorycreate,
      categoryupdate: data['updateAt'] as Timestamp? ?? categoryupdate,
      categorydelete: data['deletedAt'] as Timestamp? ?? categorydelete,
      categorydeleteyn: data['delete'] as bool? ?? categorydeleteyn,
      categorydeletenote: data['deleteNote'] as String? ?? categorydeletenote,
    );
  }
}

class CategoryDetail {
  final int categorycode;
  final int categorydetailcode;
  final String categorydetailname;
  final Timestamp categorycreate;
  final Timestamp? categoryupdate;
  final Timestamp? categorydelete;
  final bool categorydeleteyn;
  final String? categorydeletenote;

  CategoryDetail({
    required this.categorycode,
    required this.categorydetailcode,
    required this.categorydetailname,
    required this.categorycreate,
    this.categoryupdate,
    this.categorydelete,
    required this.categorydeleteyn,
    this.categorydeletenote,
  });

  factory CategoryDetail.fromFirebase(Map<String, dynamic> data) {
    return CategoryDetail(
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
