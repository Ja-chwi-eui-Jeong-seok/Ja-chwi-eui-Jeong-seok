import 'package:flutter/material.dart';

class HeartButton extends StatelessWidget {
  const HeartButton({
    required this.liked,
    required this.count,
    required this.onPressed,
  });
  final bool liked;
  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onPressed, // VM 토글 호출
          icon: Icon(
            liked ? Icons.favorite : Icons.favorite_border,
            color: liked ? Colors.red : Colors.black,
            size: 18,
          ),
        ),
        Text(
          // NumberFormat.compact().format(count), 압축 표기
          '$count',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ],
    );
  }
}
