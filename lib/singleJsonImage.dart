import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SingleJsonImage extends StatefulWidget {
  @override
  _SingleJsonImageState createState() => _SingleJsonImageState();
}

class _SingleJsonImageState extends State<SingleJsonImage> {
  String? imagePath;

  @override
  void initState() {
    super.initState();
    loadImageFromJson();
  }

  Future<void> loadImageFromJson() async {
    final String response = await rootBundle.loadString(
      'assets/config/images.json',
    );
    final data = json.decode(response);
    setState(() {
      imagePath = data['image'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("단일 JSON 이미지 로드")),
      body: Center(
        child: Lottie.asset(
          'assets/config/main.json',
          repeat: true,
          animate: true,
        ),
      ),
    );
  }
}
