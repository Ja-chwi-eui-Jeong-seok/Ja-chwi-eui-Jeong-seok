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
