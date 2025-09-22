import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ja_chwi/core/config/router/router.dart';
import 'package:ja_chwi/core/config/theme/app_theme.dart';
import 'package:ja_chwi/firebase_options.dart';
// import 'package:ja_chwi/presentation/screens/auth/login_screen.dart';
// import 'package:ja_chwi/presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
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
