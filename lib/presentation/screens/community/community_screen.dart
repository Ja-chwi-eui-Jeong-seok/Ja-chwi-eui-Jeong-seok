import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ja_chwi/domain/entities/category.dart';
import 'package:ja_chwi/presentation/common/utils/string_utils.dart';
import 'package:ja_chwi/presentation/providers/user_provider.dart';
import 'package:ja_chwi/presentation/screens/community/vm/category_vm.dart';
import 'package:ja_chwi/presentation/screens/community/vm/community_list_vm.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';

//커뮤니티 화면 (카테고리 탭 2단구조 + 게시글 패치)
class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //카테고리 상태 구독
    final catState = ref.watch(categoryVMProvider);
    //더미유저데이터
    final uid = ref.read(currentUidProvider);
    return catState.parents.when(
      //로딩
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      //에러
      error: (e, _) => Scaffold(
        body: Center(child: Text('카테고리 오류: $e')),
      ),
      //데이터
      data: (parents) {
        if (parents.isEmpty) {
          return const Scaffold(body: Center(child: Text('카테고리가 없습니다')));
        }
        //1 depth 카테고리
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
                  Text('동작구'), //현재 유저 프로필에 설정된 위치 표시해야함
                  Spacer(),
                ],
              ),
              bottom: TabBar(
                //텝 스크롤
                isScrollable:
                    false, //true로 하면 동일한 가로너비로 되지 않게됌. 스크롤불가능으로해야 스타일이 맞음
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),

                labelColor: Colors.black,

                //
                //밑줄 커스텀
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(color: Colors.black, width: 3),
                  insets: EdgeInsets.symmetric(horizontal: 16),
                ),
                indicatorSize: TabBarIndicatorSize.tab, // 탭 전체 밑줄
                indicatorColor: Colors.black,
                //1차탭
                tabs: parents.map((p) => Tab(text: p.categoryName)).toList(),
              ),
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              // 상위 탭 선택 시, 하위 탭(_SecondDepthTabs)으로 이동
              children: parents.map((p) {
                return _SecondDepthTabs(parentCode: p.categoryCode);
              }).toList(),
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: FloatingActionButton.small(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                //글쓰기 버튼 자리
                onPressed: () {
                  //로그인처리확인

                  if (uid == null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(content: Text('로그인이 필요합니다.')),
                    );
                    return;
                  }
                  //uid를 extra로 넘김, 넘긴후 글쓰기 화면에서 uid로 위치조회
                  context.push('/community-create', extra: uid);
                },
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                child: const Icon(Icons.edit),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 상위 탭(부모 카테고리) → 하위 탭(세부 카테고리)을 표시하는 위젯
class _SecondDepthTabs extends ConsumerStatefulWidget {
  const _SecondDepthTabs({required this.parentCode});
  final int parentCode;

  @override
  ConsumerState<_SecondDepthTabs> createState() => _SecondDepthTabsState();
}

class _SecondDepthTabsState extends ConsumerState<_SecondDepthTabs> {
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 처음 뜰 때 하위 카테고리 로드 (한 번만 실행됨)
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
    // 상위 카테고리 상태에서, 선택한 parentCode 의 children 가져오기
    final state = ref.watch(categoryVMProvider);
    final av = state.children[widget.parentCode];
    //아직 없으면 로딩표시
    if (av == null || av.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    //하위 카테고리 데이터처리
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
              //두번째 탭바
              _CategoryDetailChips(subs: subs),
              // 하위 탭뷰: 각 하위 카테고리의 게시글 리스트 영역(placeholder)
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: subs.map((s) {
                    return _PostsPlaceholder(
                      parentCode: widget.parentCode,
                      detailCode: s.categoryDetailCode,
                      detailName: s.categoryDetailName,
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

/// 게시글 목록 표시
class _PostsPlaceholder extends ConsumerStatefulWidget {
  const _PostsPlaceholder({
    required this.parentCode,
    required this.detailCode,
    required this.detailName,
  });
  final int parentCode;
  final int detailCode;
  final String detailName;

  @override
  ConsumerState<_PostsPlaceholder> createState() => _PostsPlaceholderState();
}

class _PostsPlaceholderState extends ConsumerState<_PostsPlaceholder> {
  // CommunityListVM 을 위한 provider
  late final NotifierProvider<CommunityListVM, CommunityListState> provider =
      communityListVmProvider(
        categoryCode: widget.parentCode,
        detailCode: widget.detailCode,
        location: '동작구', //유저 프로필 > 프로필에서 위치값 현재는 임의로 동작구지정
      );

  @override
  void initState() {
    super.initState();
    // 첫 진입 시 초기 데이터 로드
    Future.microtask(() => ref.read(provider.notifier).loadInitial(ref));
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(provider);
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (!st.hasMore || st.isLoading) return false; // 가드
          if (n.metrics.pixels >= n.metrics.maxScrollExtent * 0.9) {
            ref.read(provider.notifier).loadMore(ref);
          }
          return false;
        },

        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    widget.detailName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  //쓸지안쓸지 모름..안쓸것같음
                  const Text(
                    '최신순',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Text('  |  ', style: TextStyle(color: Colors.grey)),
                  const Text('추천순', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 게시글 리스트
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 100,
                ),
                itemCount:
                    st.items.length + ((st.isLoading && st.hasMore) ? 1 : 0),

                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  if (i >= st.items.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final x = st.items[i];
                  final date = DateFormat(
                    'yyyy.MM.dd',
                  ).format(x.communityCreateDate);
                  // likeCount 필드가 아직 없으면 0으로 표시
                  final likeCount = 0;

                  return InkWell(
                    onTap: () => context.push(
                      '/community-detail',
                      extra: x.id,
                    ), // x: Community
                    child: Container(
                      height: 96,
                      //테두리
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFF2F2F2), width: 3),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 좌측 텍스트
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      // 제목
                                      StringUtils.truncateWithEllipsis(
                                        15,
                                        x.communityName,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      //날짜
                                      date,
                                      // style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Spacer(),

                                Row(
                                  children: [
                                    Text(
                                      //작성자(현재 임시)
                                      x.createUser,
                                      //style: const TextStyle(color: Colors.grey),
                                    ),
                                    Spacer(),
                                    const Icon(Icons.favorite_border, size: 18),
                                    const SizedBox(width: 4),

                                    Text('$likeCount'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // 우측 하트
                          Row(
                            children: [],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        mode: BottomNavMode.tab,
      ),
    );
  }
}

class _CategoryDetailChips extends StatelessWidget {
  const _CategoryDetailChips({required this.subs});
  final List<CategoryDetail> subs;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context); //!제거함

    return AnimatedBuilder(
      animation: controller.animation!,
      builder: (context, _) {
        final current = controller.index;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: List.generate(subs.length, (i) {
              final s = subs[i];
              final selected = (current == i);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () => controller.animateTo(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? Colors.black : Colors.white, // 선택 배경
                      border: Border.all(color: Colors.grey), // 항상 테두리
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      s.categoryDetailName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : Colors.black, // 선택 글자색
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
