import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HomeProgress extends StatelessWidget {
  const HomeProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: LinearPercentIndicator(
        lineHeight: 20.0,
        percent: 0.65, // 65% 진행
        barRadius: const Radius.circular(10), // 모서리 둥글게
        linearGradient: const LinearGradient(
          colors: [
            Color(0xFF7FA8DA), // sky
            Color(0xFF6664CE), // night
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        backgroundColor: Colors.grey.shade300,
        center: Text(
          "65%",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
