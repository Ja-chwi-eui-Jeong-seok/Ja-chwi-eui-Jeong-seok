import 'package:ja_chwi/data/dto/category_code_dto.dart';
import 'package:ja_chwi/data/dto/category_detail_dto.dart';

abstract interface class CategoryDataSource {
  //카테고리 코드 불러오기
  Future<List<CategoryCodeDto>> fetchCategoryCodes();
  //카테고리 detail 코드 불러오기
  Future<List<CategoryDetailDto>> fetchCategoryDetails(int categoryCode);
}
