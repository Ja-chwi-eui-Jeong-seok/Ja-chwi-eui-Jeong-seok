import 'package:ja_chwi/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> fetchCategoryCodes();
  Future<List<CategoryDetail>> fetchCategoryDetails(int categoryCode);
}
