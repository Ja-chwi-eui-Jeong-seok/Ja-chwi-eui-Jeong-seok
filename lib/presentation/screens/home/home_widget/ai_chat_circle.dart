import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AiChatCircle extends StatelessWidget {
  final Offset? center; // 선택적
  final double? radius; // 선택적
  final IconData icon;
  final VoidCallback? onTap;

  const AiChatCircle({
    super.key,
    this.center,
    this.radius,
    this.icon = CupertinoIcons.chat_bubble_text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 여기서 size 정의
    final size = MediaQuery.of(context).size;

    // Guide3에서 center/radius를 주면 그걸 쓰고,
    // HomeScreen에서는 기본 위치/크기 계산
    final defaultCenter = Offset(size.width * 0.73, size.height * 0.464);
    final defaultRadius = size.width * 0.07;

    final effectiveCenter = center ?? defaultCenter;
    final effectiveRadius = radius ?? defaultRadius;

    return Positioned(
      left: effectiveCenter.dx - effectiveRadius,
      top: effectiveCenter.dy - effectiveRadius,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: effectiveRadius * 2,
          height: effectiveRadius * 2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: effectiveRadius,
          ),
        ),
      ),
    );
  }
}
