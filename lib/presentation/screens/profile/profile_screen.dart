import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_header.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_nickname_input.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_grid.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Screen')),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            ProfileHeader(step: 0,),
            ProfileNicknameInput(),
            //ProfileGrid(),
          ],
        ),
      ),
       bottomNavigationBar:BottomNav(
                            mode: BottomNavMode.confirm,
                            confirmRoute: '/home',
                          ) // 불러오기만 하면 됨
       //bottomNavigationBar:BottomNav(mode: BottomNavMode.tab)
    );
  }
}