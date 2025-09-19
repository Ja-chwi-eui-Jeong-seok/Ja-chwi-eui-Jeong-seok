import 'package:flutter/material.dart';

class AiChatCircle extends StatelessWidget {
  final double circleSize;
  final double offsetX;
  final double offsetY;
  final IconData icon;
  final VoidCallback? onTap;

  const AiChatCircle({
    super.key,
    this.circleSize = 60,
    this.offsetX = 50,
    this.offsetY = 20,
    this.icon = Icons.chat,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: offsetY,
      right: -offsetX,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: circleSize * 0.5,
          ),
        ),
      ),
    );
  }
}
