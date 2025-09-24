import 'package:ja_chwi/domain/entities/category.dart';
import 'package:ja_chwi/domain/repositories/category_repository.dart';
import 'package:ja_chwi/domain/usecases/usecase.dart';

class GetCategory implements Usecase<List<Category>, void> {
  final CategoryRepository repo;
  GetCategory(this.repo);

  @override
  Future<List<Category>> call(void _) => repo.fetchCategoryCodes();
}

class GetCategoryDetails implements Usecase<List<CategoryDetail>, int> {
  final CategoryRepository repo;
  GetCategoryDetails(this.repo);

  @override
  Future<List<CategoryDetail>> call(int categoryCode) =>
      repo.fetchCategoryDetails(categoryCode);
}
