import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/data/datasources/category_data_source.dart';
import 'package:ja_chwi/data/datasources/category_data_source_impl.dart';
import 'package:ja_chwi/data/repositories/category_repository_impl.dart';
import 'package:ja_chwi/domain/repositories/category_repository.dart';
import 'package:ja_chwi/domain/usecases/get_category_usecase.dart';

//datasource
final categoryDataSourceProvider = Provider<CategoryDataSource>(
  (ref) => CategoryDataSourceImpl(FirebaseFirestore.instance),
);

//repository
final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(ref.read(categoryDataSourceProvider)),
);

//usecase
final getCategoryProvider = Provider<GetCategory>(
  (ref) => GetCategory(ref.read(categoryRepositoryProvider)),
);

final getCategoryDetailsProvider = Provider<GetCategoryDetails>(
  (ref) => GetCategoryDetails(ref.read(categoryRepositoryProvider)),
);
