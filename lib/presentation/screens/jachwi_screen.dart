import 'package:flutter/material.dart';

// 화면 단위 UI 위젯

class JachwiScreen extends StatelessWidget {
  const JachwiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Jachwi Screen')),
      body: Center(child: Text('This is the Jachwi screen')),
    );
  }
}
