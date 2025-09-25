import 'package:image_picker/image_picker.dart';

abstract class ImagePickerDataSource {
  /// 갤러리에서 여러 이미지를 선택합니다.
  Future<List<XFile>> pickMultiImage();
}
