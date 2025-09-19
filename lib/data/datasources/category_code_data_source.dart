import 'package:ja_chwi/data/dto/category_code_dto.dart';

abstract interface class CategoryCodeDataSource {
  Future<CategoryCodeDto> fetchCategoryCode(int code);
}
