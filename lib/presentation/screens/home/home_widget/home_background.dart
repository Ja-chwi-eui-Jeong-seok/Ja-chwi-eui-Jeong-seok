import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: -440,
          left: -650,
          right: -650,
          child: Container(
            height: 850,
            decoration: BoxDecoration(
              color: Color(0xFFD9D9D9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(850)),
            ),
          ),
        ),
      ],
    );
  }
}
