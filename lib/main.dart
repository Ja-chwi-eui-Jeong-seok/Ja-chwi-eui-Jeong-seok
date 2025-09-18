import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ja_chwi/core/config/router/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ja_chwi/firebase_options.dart';

void main() async {
  // Firebase 초기화 전에 반드시 호출되어야 함
  WidgetsFlutterBinding.ensureInitialized();
  // 플랫폼에 맞는 Firebase 설정을 사용하여 앱을 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
        // 스크롤 시 AppBar 색상이 변하는 것을 방지하기 위한 글로벌 테마 설정
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Scaffold 배경색과 동일하게 설정
          surfaceTintColor: Colors.transparent, // 스크롤 시 색상 변경 효과 제거
          elevation: 0, // AppBar의 그림자 제거
        ),
      ),
      routerConfig: router,
    );
  }
}
