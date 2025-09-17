import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/domain/usecases/get_images_usecase.dart';
import 'package:ja_chwi/domain/entities/image_entity.dart';
import 'package:ja_chwi/data/datasources/image_datasource.dart';
import 'package:ja_chwi/domain/repositories/image_repository.dart';

// UseCase Provider
final getImagesUseCaseProvider = Provider<GetImagesUseCase>((ref) {
  final dataSource = ImageDataSourceImpl();
  final repository = ImageRepositoryImpl(dataSource);
  return GetImagesUseCase(repository);
});

// Image List Provider
final imageListProvider = FutureProvider<List<ImageEntity>>((ref) async {
  return await ref.watch(getImagesUseCaseProvider).execute();
});

// Selected Image State Provider
final selectedImageProvider =
    StateProvider<String>((ref) => 'assets/images/profile/black.png');
