import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('개인정보처리방침')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  // 아래 텍스트는 예시로 대충 만든것임
                  // 노션 등 개인정보처리방침 페이지를 만들면 링크 걸 예정
                  '''
개인정보처리방침

1. 수집하는 개인정보 항목
   - 이메일, 이름, 기기 정보

2. 개인정보 수집 목적
   - 로그인 및 서비스 제공

3. 보관 및 이용 기간
   - 탈퇴 시 즉시 삭제

4. 제3자 제공 여부
   - Firebase, Google 등

5. 이용자의 권리
   - 열람, 수정, 삭제 가능

6. 문의처
   - email 넣기
                  ''',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    print('push');
                    context.go('/home');
                  },
                  child: const Text('동의'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
