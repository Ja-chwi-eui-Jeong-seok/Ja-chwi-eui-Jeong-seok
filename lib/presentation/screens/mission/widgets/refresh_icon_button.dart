import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RefreshIconButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const RefreshIconButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        'assets/images/icons/reload.png',
        width: 25,
        height: 25,
      ),
      onPressed: onPressed ?? () {},
    );
  }
}
