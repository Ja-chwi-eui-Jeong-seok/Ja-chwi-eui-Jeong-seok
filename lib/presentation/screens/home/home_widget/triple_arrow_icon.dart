import 'package:flutter/material.dart';

class TripleArrowIcon extends StatelessWidget {
  final double size;

  const TripleArrowIcon({
    super.key,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.translate(
          offset: Offset(size * 2 / 3, 0),
          child: Icon(
            Icons.arrow_forward_ios,
            color: const Color(0xFF8F8F8F),
            size: size,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, 0),
          child: Icon(
            Icons.arrow_forward_ios,
            color: const Color(0xFF666666),
            size: size,
          ),
        ),
        Transform.translate(
          offset: Offset(-size * 2 / 3, 0),
          child: Icon(
            Icons.arrow_forward_ios,
            color: const Color(0xFF342E37),
            size: size,
          ),
        ),
      ],
    );
  }
}
