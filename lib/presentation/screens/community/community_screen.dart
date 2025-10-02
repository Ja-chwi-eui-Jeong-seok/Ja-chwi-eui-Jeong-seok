import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ja_chwi/domain/entities/category.dart';
import 'package:ja_chwi/presentation/common/utils/string_utils.dart';
import 'package:ja_chwi/presentation/providers/comment_usecase_provider.dart';
import 'package:ja_chwi/presentation/providers/user_profile_by_uid_provider.dart.dart';
import 'package:ja_chwi/presentation/screens/community/vm/category_vm.dart';
import 'package:ja_chwi/presentation/screens/community/vm/community_list_vm.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/nick_name.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/no_location_view.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';
import 'package:timezone/timezone.dart' as tz;

//커뮤니티 화면 (카테고리 탭 2단구조 + 게시글 패치)
class CommunityScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;
  const CommunityScreen({super.key, this.extra});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    final extra = widget.extra;
    if (kDebugMode) debugPrint('CommunityScreen extra: $extra');

    final catState = ref.watch(categoryVMProvider);

    // 프로필 통해 위치 얻기
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final profileAv = uid == null
        ? const AsyncValue.loading()
        : ref.watch(profileByUidProvider(uid));
    final String? location = profileAv.maybeWhen(
      data: (p) => p.dongName,
      orElse: () => null,
    );
    final hasLocation = (location != null && location.isNotEmpty);

    return catState.parents.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('카테고리 오류: $e'))),
      data: (parents) {
        if (parents.isEmpty) {
          return const Scaffold(body: Center(child: Text('카테고리가 없습니다')));
        }
        //오름차순 정렬
        parents.sort((a, b) => a.categoryCode.compareTo(b.categoryCode));
        return DefaultTabController(
          length: parents.length,
          child: Scaffold(
            appBar: AppBar(
              titleSpacing: 10,
              title: Row(
                children: [
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_down),
                  const SizedBox(width: 4),
                  Text(location ?? '위치를 등록해주세요'),
                  const Spacer(),
                ],
              ),
              bottom: TabBar(
                isScrollable: false,
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                labelColor: Colors.black,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(color: Colors.black, width: 3),
                  insets: EdgeInsets.symmetric(horizontal: 16),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: parents.map((p) => Tab(text: p.categoryName)).toList(),
              ),
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: parents.map((p) {
                return hasLocation
                    ? _SecondDepthTabs(
                        parentCode: p.categoryCode,
                        location: location,
                      )
                    : const NoLocationView();
              }).toList(),
            ),
            floatingActionButton: FloatingActionButton.small(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              onPressed: () {
                if (uid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그인이 필요합니다.')),
                  );
                  return;
                }
                if (!hasLocation) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('위치 등록 후 글쓰기가 가능합니다.')),
                  );
                  return;
                }
                context.push('/community-create', extra: uid);
              },
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              child: const Icon(Icons.edit),
            ),
            bottomNavigationBar: BottomNav(
              mode: BottomNavMode.tab,
              userData: extra,
            ),
          ),
        );
      },
    );
  }
}

/// 상위 탭(부모 카테고리) → 하위 탭(세부 카테고리)을 표시하는 위젯
class _SecondDepthTabs extends ConsumerStatefulWidget {
  const _SecondDepthTabs({required this.parentCode, required this.location});
  final int parentCode;
  final String? location;

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
        subs.sort(
          (a, b) => a.categoryDetailCode.compareTo(b.categoryDetailCode),
        );
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
                      location: widget.location,
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
    required this.location,
  });
  final int parentCode;
  final int detailCode;
  final String detailName;
  final String? location;

  @override
  ConsumerState<_PostsPlaceholder> createState() => _PostsPlaceholderState();
}

class _PostsPlaceholderState extends ConsumerState<_PostsPlaceholder> {
  // build에서 만들지 말고, 필드로 고정
  late NotifierProvider<CommunityListVM, CommunityListState> provider;
  bool _ready = false; // provider 준비 여부

  // 댓글수 캐시
  final Map<String, Future<int>> _commentCountFutures = {};

  @override
  void initState() {
    super.initState();
    _maybeInitProviderAndLoad();
  }

  @override
  void didUpdateWidget(covariant _PostsPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // location이 뒤늦게 생기거나 변경되면 재초기화
    if (oldWidget.location != widget.location) {
      _ready = false;
      _maybeInitProviderAndLoad();
    }
  }

  void _maybeInitProviderAndLoad() {
    final loc = widget.location;
    if (loc == null || loc.isEmpty) return; // 아직 준비 안됨

    provider = communityListVmProvider(
      categoryCode: widget.parentCode,
      detailCode: widget.detailCode,
      location: loc,
    );
    _ready = true;

    // 초기 로드 1회
    Future.microtask(() {
      if (!mounted) return;
      ref.read(provider.notifier).loadInitial(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    // location 없거나 provider 아직 준비 안됐으면 안내뷰
    if (!_ready) return const NoLocationView();

    final st = ref.watch(provider);
    // 빈 목록/로딩 처리
    if (st.items.isEmpty) {
      return Scaffold(
        body: Column(
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
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: st.isLoading
                    ? const CircularProgressIndicator()
                    : const Padding(
                        padding: EdgeInsets.only(bottom: 100),
                        child: Text(
                          '아직 게시글이 없습니다',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (!st.hasMore || st.isLoading) return false;
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
                  //TODO: 정렬기능
                  // const Text(
                  //   '최신순',
                  //   style: TextStyle(fontWeight: FontWeight.w600),
                  // ),
                  // const Text('  |  ', style: TextStyle(color: Colors.grey)),
                  // const Text('인기순', style: TextStyle(color: Colors.grey)),
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
                  final tz.Location seoul = tz.getLocation('Asia/Seoul');
                  final date =
                      DateFormat(
                        'yyyy.MM.dd',
                      ).format(
                        tz.TZDateTime.from(
                          x.communityCreateDate.toUtc(),
                          seoul,
                        ),
                      );

                  //댓글수
                  final countFuture = _commentCountFutures.putIfAbsent(
                    x.id,
                    () => ref.read(getCommentCountProvider).call(x.id),
                  );
                  return InkWell(
                    onTap: () => context.push(
                      '/community-detail',
                      extra: x.id,
                    ),
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
                                    ),
                                  ],
                                ),
                                Spacer(),

                                Row(
                                  children: [
                                    NickName(
                                      uid: x.createUser,
                                    ),
                                    Spacer(),
                                    //댓글수 표시
                                    const Icon(
                                      Icons.mode_comment_outlined,
                                      size: 18,
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    FutureBuilder(
                                      future: countFuture,
                                      builder: (_, snap) {
                                        if (snap.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          );
                                        }
                                        final c = snap.data ?? 0;
                                        return Text('$c');
                                      },
                                    ),
                                    //const SizedBox(width: 10),
                                    //TODO: 스크랩
                                    //const Icon(Icons.bookmark_border, size: 18),
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
