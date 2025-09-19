// lib/image_list/domain/usecases/get_images_usecase.dart
import '../entities/image_entity.dart';
import '../repositories/image_repository.dart';

class GetImagesUseCase {
  final ImageRepository repository;

  GetImagesUseCase(this.repository);

  Future<List<ImageEntity>> execute() {
    return repository.getImages();
  }
}