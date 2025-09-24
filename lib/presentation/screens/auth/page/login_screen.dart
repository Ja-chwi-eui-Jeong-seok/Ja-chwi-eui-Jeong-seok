import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/data/datasources/auth_datasource.dart';
import 'package:ja_chwi/data/datasources/auth_datasource_impl.dart';
import 'package:ja_chwi/domain/usecases/auth_usecase.dart';
import 'package:ja_chwi/presentation/screens/auth/login_widget/login_button.dart';
import 'package:ja_chwi/presentation/screens/auth/login_widget/wave_text.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  // 한 번만 생성하고 재사용
  final repository = AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(),
  );

  late final googleUseCase = SignInWithGoogleUseCase(repository);
  late final appleUseCase = SignInWithAppleUseCase(repository);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WaveText(text: '자취의 정석 \n 시작하기'),
                    const SizedBox(height: 40),
                    Image.asset(
                      'assets/images/profile/black.png',
                      width: 150,
                      height: 150,
                    ),
                  ],
                ),
              ),
            ),
            LoginButton(
              googleUseCase: googleUseCase,
              appleUseCase: appleUseCase,
              onLoginSuccess: () async {
                final accepted = await context.push<bool>('/privacy-policy');
                if (!context.mounted) return;

                if (accepted == true) {
                  await context.push('/profile');
                  if (!context.mounted) return;
                  context.go('/home');
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
