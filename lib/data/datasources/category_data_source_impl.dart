import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/datasources/category_data_source.dart';
import 'package:ja_chwi/data/dto/category_code_dto.dart';
import 'package:ja_chwi/data/dto/category_detail_dto.dart';

class CategoryDataSourceImpl implements CategoryDataSource {
  final FirebaseFirestore firestore;
  CategoryDataSourceImpl(this.firestore);

  //카테고리 코드 불러오기
  @override
  Future<List<CategoryCodeDto>> fetchCategoryCodes() async {
    final snapshot = await firestore.collection('categorycode').get();

    return snapshot.docs
        .map((doc) => CategoryCodeDto.fromFirebase(doc.data()))
        .toList();
  }

  //카테고리 detail 코드 불러오기
  @override
  Future<List<CategoryDetailDto>> fetchCategoryDetails(int categoryCode) async {
    final snapshot = await firestore
        .collection('categorydetail')
        .where('category_code', isEqualTo: categoryCode)
        .get();

    return snapshot.docs
        .map((doc) => CategoryDetailDto.fromFirebase(doc.data()))
        .toList();
  }
}
