import 'dart:math';

import 'package:flutter/material.dart';

// aichat
class AiChatCircleConfig {
  static Offset getCenter(Size size) {
    return Offset(size.width * 0.73, size.height * 0.464);
  }

  static double getRadius(Size size) {
    return size.width * 0.05;
  }
}

// Guide3
class GuideCircleConfig {
  static Offset getCenter(Size size) {
    return Offset(size.width * 0.73, size.height * 0.464);
  }

  static double getRadius(Size size) {
    return size.width * 0.07;
  }
}

// // Guide4
// class Guide4CircleConfig {
//   static Offset getCenter(Size size) {
//     return Offset(size.width * 0.385, size.height * 0.921);
//   }

//   static double getRadius(Size size) {
//     return min(size.width, size.height) * 0.07;
//   }
// }

// // Guide5
// class Guide5CircleConfig {
//   static Offset getCenter(Size size) {
//     return Offset(size.width * 0.613, size.height * 0.921);
//   }

//   static double getRadius(Size size) {
//     return min(size.width, size.height) * 0.07;
//   }
// }
