import 'package:flutter/material.dart';

class RefreshIconButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const RefreshIconButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.refresh, color: Colors.black),
      onPressed: onPressed ?? () {},
    );
  }
}
