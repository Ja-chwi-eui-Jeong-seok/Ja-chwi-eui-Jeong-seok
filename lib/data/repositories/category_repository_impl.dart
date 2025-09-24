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
            categorycode: dto.categorycode,
            categoryname: dto.categoryname,
            categorycreate: dto.categorycreate,
            categoryupdate: dto.categoryupdate,
            categorydelete: dto.categorydelete,
            categorydeleteyn: dto.categorydeleteyn,
            categorydeletenote: dto.categorydeletenote,
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
            categorycode: dto.categorycode,
            categorycreate: dto.categorycreate,
            categoryupdate: dto.categoryupdate,
            categorydelete: dto.categorydelete,
            categorydeleteyn: dto.categorydeleteyn,
            categorydeletenote: dto.categorydeletenote,
            categorydetailcode: dto.categorydetailcode,
            categorydetailname: dto.categorydetailname,
          ),
        )
        .toList();
  }
}
