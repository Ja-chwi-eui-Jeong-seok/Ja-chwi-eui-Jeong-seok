import 'package:ja_chwi/domain/entities/image_entity.dart';
class ImageModel {
  final String id;
  final String thumbUrl;
  final String fullUrl;

  ImageModel({
    required this.id,
    required this.thumbUrl,
    required this.fullUrl,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      thumbUrl: json['thumbUrl'],
      fullUrl: json['fullUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thumbUrl': thumbUrl,
      'fullUrl': fullUrl,
    };
  }

  ImageEntity toEntity() {
    return ImageEntity(
      id: id,
      thumbUrl: thumbUrl,
      fullUrl: fullUrl,
    );
  }
}