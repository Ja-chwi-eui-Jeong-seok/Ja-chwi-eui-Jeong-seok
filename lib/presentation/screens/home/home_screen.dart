import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/home_background.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/monji_jump.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';

//해야할 것:
// 1 레벨 올라가는 부분,
// 1 미션 버튼 만들고 넘어가기,
// 2 하단 네비 연결,
// 3 하단 그라데이션, 앱바 종아이콘,
// 4 ai챗 버튼,

//가이드 화면도 들어가기

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '자취의 정석',
          style: TextStyle(
            fontFamily: 'GamjaFlower',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          const HomeBackground(),
          //레벨// 위젯으로 빼거나 불러오가
          Padding(
            padding: const EdgeInsets.all(23),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 80,
                  color: Colors.blue,
                ),
                SizedBox(height: 20),
                //미션// 미션페이지에서 오늘의 미션 불러오기
                Container(
                  width: double.infinity,
                  height: 80,
                  color: Colors.green,
                ),
                SizedBox(height: 58),
                //캐릭터//json으로 걷는 애니메이션 만들고 불러오기?
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topCenter,
                  child: Center(child: MonjiJump()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
