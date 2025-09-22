import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HomeProgress extends StatelessWidget {
  const HomeProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 레벨 알약
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Lv. 12',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // 경험치
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '640/808',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 진행 바
          Stack(
            children: [
              LinearPercentIndicator(
                lineHeight: 10.0,
                percent: 0.65,
                barRadius: const Radius.circular(10),
                linearGradient: const LinearGradient(
                  colors: [
                    Color(0xFF7FA8DA),
                    Color(0xFF6664CE),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                backgroundColor: Colors.grey.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
