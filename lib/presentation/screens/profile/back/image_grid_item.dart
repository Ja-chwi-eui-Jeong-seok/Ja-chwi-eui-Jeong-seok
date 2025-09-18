import 'package:flutter/material.dart';
import 'package:ja_chwi/domain/entities/image_entity.dart';

class ImageGridItem extends StatelessWidget {
  final ImageEntity image;
  final VoidCallback onTap;

  const ImageGridItem({
    super.key,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(image.thumbUrl, fit: BoxFit.cover),
       //Image.network() 는 인터넷 URL 전용
    );
  }
}

//역할: 상단 오렌지 영역, 기본 블랙 이미지 표시, 클릭 시 GridView에서 바뀜
//재사용 가능: 다른 페이지에서 그냥 ProfileHeader() 호출