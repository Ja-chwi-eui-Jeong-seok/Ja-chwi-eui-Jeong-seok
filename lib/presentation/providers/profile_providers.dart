import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/data/repositories/profile_repository_impl.dart';
import 'package:ja_chwi/data/datasources/profile_datasource.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

// 닉네임 상태
final nicknameProvider = StateProvider<String?>((ref) => null);

// 프로필 이미지 상태
class ProfileImage {
  final String id;
  final String thumbUrl;
  final String fullUrl;
  final String color;

  ProfileImage({required this.id, required this.thumbUrl, required this.fullUrl,required this.color});

  factory ProfileImage.fromJson(Map<String, dynamic> json) {
    return ProfileImage(
      id: json['id'],
      thumbUrl: json['thumbUrl'],
      fullUrl: json['fullUrl'],
      color: json['color'],
    );
  }
}

// 이미지 리스트 Provider
final profileImagesProvider = FutureProvider<List<ProfileImage>>((ref) async {
  final jsonString = await rootBundle.loadString('assets/config/json/images.json');
  final List<dynamic> data = jsonDecode(jsonString);
  return data.map((e) => ProfileImage.fromJson(e)).toList();
});

// 선택된 이미지
final selectedImageProvider = StateProvider<ProfileImage?>((ref) => null);

// Firebase Repository
final profileRepositoryProvider = Provider<ProfileRepositoryImpl>((ref) {
  final dataSource = FirebaseProfileDataSource();
  return ProfileRepositoryImpl(dataSource);
});