import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      body: const Center(child: Text('LoginScreen Screen')),
    );
  }
}
