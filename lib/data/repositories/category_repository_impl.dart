import 'package:ja_chwi/data/datasources/category_data_source.dart';
import 'package:ja_chwi/domain/entities/category.dart';
import 'package:ja_chwi/domain/repositories/category_repository.dart';

// DTO → Entity 변환 책임
// → Domain 계층에서는 Entity만 바라본다.
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDataSource categoryDataSource;
  CategoryRepositoryImpl(this.categoryDataSource);

  //카테고리코드
  @override
  Future<List<Category>> fetchCategoryCodes() async {
    final source = await categoryDataSource.fetchCategoryCodes();

    return source
        .map(
          (dto) => Category(
            categoryCode: dto.categorycode,
            categoryName: dto.categoryname,
            categoryCreate: dto.categorycreate,
            categoryUpdate: dto.categoryupdate,
            categoryDelete: dto.categorydelete,
            categoryDeleteYn: dto.categorydeleteyn,
            categoryDeleteNote: dto.categorydeletenote,
          ),
        )
        .toList();
  }

  //카테고리디테일코드
  @override
  Future<List<CategoryDetail>> fetchCategoryDetails(int categoryCode) async {
    final source = await categoryDataSource.fetchCategoryDetails(categoryCode);
    return source
        .map(
          (dto) => CategoryDetail(
            categoryCode: dto.categorycode,
            categoryCreate: dto.categorycreate,
            categoryUpdate: dto.categoryupdate,
            categoryDelete: dto.categorydelete,
            categoryDeleteYn: dto.categorydeleteyn,
            categoryDeleteNote: dto.categorydeletenote,
            categoryDetailCode: dto.categorydetailcode,
            categoryDetailName: dto.categorydetailname,
          ),
        )
        .toList();
  }
}
