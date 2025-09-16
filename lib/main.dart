import 'package:flutter/material.dart';
import 'package:ja_chwi/core/config/router/router.dart';
import 'package:ja_chwi/presentation/screens/auth/login_screen.dart';
import 'package:ja_chwi/presentation/screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // return MaterialApp.router(
    //   routerConfig: router, // go_router
    //   title: '자취의정석',
    //   debugShowCheckedModeBanner: false,
    // );
    return MaterialApp(home: LoginScreen());
  }
}
