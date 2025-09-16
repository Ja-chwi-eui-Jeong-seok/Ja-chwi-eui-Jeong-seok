import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ja_chwi/presentation/screens/mission/mission_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '자취의 정석',
      // 디버그 표시
      debugShowCheckedModeBanner: false,
      // 달력 한글화를 위한 설정
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
      locale: const Locale('ko', 'KR'),
      theme: ThemeData(
        // 앱의 전체적인 배경색을 흰색으로 설정
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MissionScreen(),
    );
  }
}
