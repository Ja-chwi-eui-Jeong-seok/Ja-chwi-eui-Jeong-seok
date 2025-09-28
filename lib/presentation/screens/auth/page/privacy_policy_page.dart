import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  Future<void> _setConsent(bool consent, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_consent', consent);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'privacy_consent': consent},
        SetOptions(merge: true), // 기존 필드 유지
      );
    }

    // context.go('/guide'); // 동의 여부 저장 후 이동
    context.go('/profile-flow', extra: user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse("https://www.notion.so/278e795aec4c8002bca1df539c27f6cd"),
      );

    return Scaffold(
      appBar: AppBar(title: const Text('개인정보처리방침')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: WebViewWidget(controller: controller),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _setConsent(true, context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.black),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('동의'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _checkConsent(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final consent = prefs.getBool('privacy_agreed');

  if (consent == true) {
    // 이미 동의했으면 바로 프로필 페이지로 이동
    Future.microtask(() => context.go('/profile-flow'));
  }
}
