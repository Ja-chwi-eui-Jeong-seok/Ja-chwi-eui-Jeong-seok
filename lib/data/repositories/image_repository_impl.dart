// lib/image_list/data/repositories/image_repository_impl.dart
import '../../domain/entities/image_entity.dart';
import '../datasources/image_datasource.dart';

abstract class ImageRepository {
  Future<List<ImageEntity>> getImages();
}

class ImageRepositoryImpl implements ImageRepository {
  final ImageDataSource dataSource;

  ImageRepositoryImpl(this.dataSource);

  @override
  Future<List<ImageEntity>> getImages() async {
    return await dataSource.fetchImages();
  }
}