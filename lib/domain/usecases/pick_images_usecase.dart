import 'package:image_picker/image_picker.dart';
import 'package:ja_chwi/domain/repositories/image_picker_repository.dart';

class PickImagesUseCase {
  final ImagePickerRepository repository;

  PickImagesUseCase(this.repository);

  Future<List<XFile>> execute() {
    return repository.pickMultiImage();
  }
}
