import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_header_indicator.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_tab.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_card.dart';
import 'package:ja_chwi/presentation/screens/setting/setting.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';

class ProfileDetail extends ConsumerWidget {
  const ProfileDetail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title:  Text('Profile Screen'),        
      actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 설정 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeaderIndicator(),
             ProfileTap(),
            ProfileCardList()
          ],
        ),
      ),
      //  bottomNavigationBar:BottomNav(
      //                       mode: BottomNavMode.confirm,
      //                       confirmRoute: '/home',
      //                     ) // 불러오기만 하면 됨
       bottomNavigationBar:BottomNav(mode: BottomNavMode.tab)
    );
  }
}