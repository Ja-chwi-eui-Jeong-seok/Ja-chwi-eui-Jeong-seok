import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ja_chwi/core/config/router/router.dart';
import 'package:ja_chwi/core/config/theme/app_theme.dart';
import 'package:ja_chwi/core/utils/xss.dart';
import 'package:ja_chwi/firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 금지어 CSV 로딩
  await XssFilter.loadBannedWordsFromCSV();
  // api key 
  await dotenv.load(fileName: "assets/config/env/setting.env");
  //
  runApp(
    const ProviderScope(
      // Riverpod의 전역 상태 관리 루트
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: '자취의 정석',
      debugShowCheckedModeBanner: false,

      // 테마 및 로컬라이제이션 설정
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppTheme.localizationsDelegates,
      supportedLocales: AppTheme.supportedLocales,
      locale: const Locale('ko', 'KR'),
    );
  }
}
