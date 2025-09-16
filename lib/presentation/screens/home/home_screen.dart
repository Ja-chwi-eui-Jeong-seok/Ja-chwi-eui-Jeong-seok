import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('자취의 정석')),
      body: Column(
        children: [
          //레벨
          Container(
            width: double.infinity,
            height: 80,
            padding: const EdgeInsets.all(16),
            color: Colors.blue,
          ),

          //미션
          Container(
            width: double.infinity,
            height: 100,
            padding: const EdgeInsets.all(16),
            color: Colors.green,
          ),
          SizedBox(height: 80),

          //캐릭터
          Stack(
            children: [
              Container(
                width: 142,
                height: 162,
                padding: const EdgeInsets.all(16),
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
