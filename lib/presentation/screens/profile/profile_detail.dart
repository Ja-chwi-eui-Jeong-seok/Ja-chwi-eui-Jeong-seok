import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_header_indicator.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_tab.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_card.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';
import 'package:go_router/go_router.dart';

class ProfileDetail extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;
  const ProfileDetail({super.key, this.extra});

  @override
  ConsumerState<ProfileDetail> createState() => _ProfileDetailState();
}

class _ProfileDetailState extends ConsumerState<ProfileDetail> {
  int selectedTab = 0; // 0: 북마크, 1: 내가 쓴 글

  @override
  Widget build(BuildContext context) {
    // ✅ 여기에서는 ref를 직접 받지 않고,
    // ConsumerState 내부의 `ref` 프로퍼티를 사용합니다.
    final uid = widget.extra?['uid'] as String?;
    print('ProfileDetailScreen----> extra: ${widget.extra}');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '프로필',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go('/settings', extra: widget.extra);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ProfileHeaderIndicator(extra: widget.extra),
          ProfileTap(
            onTabChanged: (index) {
              setState(() => selectedTab = index);
            },
          ),const SizedBox(height: 10),
          Expanded(
            child: ProfileCardList(
              extra: widget.extra,
              filterType: selectedTab == 0 ? 'bookmark' : 'communitylist',
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        mode: BottomNavMode.tab,
        userData: widget.extra ?? {},
      ),
    );
  }
}
