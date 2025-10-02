import 'package:image_picker/image_picker.dart';
import 'package:ja_chwi/data/datasources/image_picker_datasource.dart';
import 'package:ja_chwi/domain/repositories/image_picker_repository.dart';

class ImagePickerRepositoryImpl implements ImagePickerRepository {
  final ImagePickerDataSource dataSource;

  ImagePickerRepositoryImpl(this.dataSource);

  @override
  Future<List<XFile>> pickMultiImage() {
    return dataSource.pickMultiImage();
  }
}
