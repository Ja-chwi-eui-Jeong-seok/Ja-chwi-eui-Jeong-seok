import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // 앱의 전체적인 배경색을 흰색으로 설정 나중에 바꿔야겠쥬?
      scaffoldBackgroundColor: Colors.white,

      // 스크롤 시 AppBar 색상이 변하는 것을 방지하기 위한 글로벌 테마 설정
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white, // Scaffold 배경색과 동일하게 설정
        surfaceTintColor: Colors.transparent, // 스크롤 시 색상 변경 효과 제거
        elevation: 0, // AppBar의 그림자 제거
        titleTextStyle: TextStyle(
          fontFamily: 'GamjaFlower', // AppBar 제목 글꼴
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),        
      ),
      fontFamily: 'GamjaFlower', // 기본 메인 폰트
      // TextTheme (본문/버튼 등 서브 폰트 Roboto 적용)
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: 'GamjaFlower'),
        displayMedium: TextStyle(fontFamily: 'GamjaFlower'),
        displaySmall: TextStyle(fontFamily: 'GamjaFlower'),
        headlineLarge: TextStyle(fontFamily: 'GamjaFlower'),
        headlineMedium: TextStyle(fontFamily: 'GamjaFlower'),
        headlineSmall: TextStyle(fontFamily: 'GamjaFlower'),
        titleLarge: TextStyle(fontFamily: 'GamjaFlower'),
        titleMedium: TextStyle(fontFamily: 'GamjaFlower'),
        titleSmall: TextStyle(fontFamily: 'GamjaFlower'),
        bodyLarge: TextStyle(fontFamily: 'Roboto'),   // 본문
        bodyMedium: TextStyle(fontFamily: 'Roboto'),  // 본문
        bodySmall: TextStyle(fontFamily: 'Roboto'),   // 캡션 등
        labelLarge: TextStyle(fontFamily: 'Roboto'),  // 버튼
        labelMedium: TextStyle(fontFamily: 'Roboto'),
        labelSmall: TextStyle(fontFamily: 'Roboto'),
      ),
    );
  }

  

  // 로컬라이제이션 delegate 설정
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  // 지원하는 로케일 설정
  static const List<Locale> supportedLocales = [Locale('ko', 'KR')];
}
