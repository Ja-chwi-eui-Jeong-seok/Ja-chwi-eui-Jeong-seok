// presentation/screens/community/community_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/screens/community/vm/category_vm.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catState = ref.watch(categoryVMProvider);

    return catState.parents.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('카테고리 오류: $e')),
      ),
      data: (parents) {
        if (parents.isEmpty) {
          return const Scaffold(body: Center(child: Text('카테고리가 없습니다')));
        }

        return DefaultTabController(
          length: parents.length,
          child: Scaffold(
            appBar: AppBar(
              titleSpacing: 10,
              title: const Row(
                children: [
                  SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down),
                  SizedBox(width: 4),
                  Text('동작구'),
                  Spacer(),
                ],
              ),
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: Colors.black,
                labelColor: Colors.black,
                tabs: parents.map((p) => Tab(text: p.categoryname)).toList(),
              ),
            ),
            body: TabBarView(
              children: parents.map((p) {
                // 상위 탭별 하위 탭(2 depth) 영역
                return _SecondDepthTabs(parentCode: p.categorycode);
              }).toList(),
            ),
            floatingActionButton: FloatingActionButton.small(
              onPressed: () {},
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              child: const Icon(Icons.edit),
            ),
          ),
        );
      },
    );
  }
}

/// 상위 탭 하나의 내용: 하위 카테고리를 탭으로 표시
class _SecondDepthTabs extends ConsumerStatefulWidget {
  const _SecondDepthTabs({required this.parentCode, super.key});
  final int parentCode;

  @override
  ConsumerState<_SecondDepthTabs> createState() => _SecondDepthTabsState();
}

class _SecondDepthTabsState extends ConsumerState<_SecondDepthTabs> {
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 최초 한 번만 children 로드
    if (!_requested) {
      _requested = true;
      Future.microtask(
        () => ref
            .read(categoryVMProvider.notifier)
            .loadChildren(widget.parentCode),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryVMProvider);
    final av = state.children[widget.parentCode];

    if (av == null || av.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return av.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('하위 카테고리 오류: $e')),
      data: (subs) {
        if (subs.isEmpty) {
          return const Center(child: Text('하위 카테고리가 없습니다'));
        }
        return DefaultTabController(
          length: subs.length,
          child: Column(
            children: [
              // 하위 탭바
              Material(
                color: Colors.white,
                child: TabBar(
                  isScrollable: true,
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  tabs: subs
                      .map((s) => Tab(text: s.categorydetailname))
                      .toList(),
                ),
              ),
              // 하위 탭뷰: 각 하위 카테고리의 게시글 리스트 영역(placeholder)
              Expanded(
                child: TabBarView(
                  children: subs.map((s) {
                    return _PostsPlaceholder(
                      parentCode: widget.parentCode,
                      detailCode: s.categorydetailcode,
                      detailName: s.categorydetailname,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 하위 탭 선택 시 실제 게시글 리스트가 들어갈 자리
/// 우선 자리표시자. 이후 페이징 VM 붙이면 교체.
class _PostsPlaceholder extends StatelessWidget {
  const _PostsPlaceholder({
    required this.parentCode,
    required this.detailCode,
    required this.detailName,
    super.key,
  });
  final int parentCode;
  final int detailCode;
  final String detailName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '$detailName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Text('최신순', style: TextStyle(fontWeight: FontWeight.w600)),
              const Text('  |  ', style: TextStyle(color: Colors.grey)),
              const Text('추천순', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
            itemCount: 8,
            itemBuilder: (_, i) => Container(
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Text('parent=$parentCode  detail=$detailCode  index=$i'),
            ),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
          ),
        ),
      ],
    );
  }
}
