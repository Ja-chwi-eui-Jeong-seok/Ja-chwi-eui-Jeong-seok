import 'package:image_picker/image_picker.dart';
import 'package:ja_chwi/data/datasources/image_picker_datasource.dart';

class ImagePickerDataSourceImpl implements ImagePickerDataSource {
  final ImagePicker _picker;

  ImagePickerDataSourceImpl(this._picker);

  @override
  Future<List<XFile>> pickMultiImage() async {
    final pickedFiles = await _picker.pickMultiImage(
      imageQuality: 80,
    );
    return pickedFiles;
  }
}
