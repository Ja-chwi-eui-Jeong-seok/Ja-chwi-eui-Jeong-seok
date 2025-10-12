import 'package:ja_chwi/domain/entities/image_entity.dart';
import 'package:ja_chwi/data/datasources/image_datasource.dart';

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
