import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:ja_chwi/domain/entities/image_entity.dart';
import 'package:ja_chwi/data/models/image_model.dart';

abstract class ImageDataSource {
  Future<List<ImageEntity>> fetchImages();
}

class ImageDataSourceImpl implements ImageDataSource {
  @override
  Future<List<ImageEntity>> fetchImages() async {
    final data = await rootBundle.loadString('assets/config/json/images.json');
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((e) => ImageModel.fromJson(e).toEntity()).toList();
  }
}
