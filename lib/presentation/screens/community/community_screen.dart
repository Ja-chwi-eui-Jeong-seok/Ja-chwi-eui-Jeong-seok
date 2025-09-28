import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ja_chwi/domain/entities/category.dart';
import 'package:ja_chwi/presentation/common/utils/string_utils.dart';
import 'package:ja_chwi/presentation/providers/comment_usecase_provider.dart';
import 'package:ja_chwi/presentation/screens/community/vm/category_vm.dart';
import 'package:ja_chwi/presentation/screens/community/vm/community_list_vm.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/nick_name.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/no_location_view.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';

//커뮤니티 화면 (카테고리 탭 2단구조 + 게시글 패치)
class CommunityScreen extends ConsumerWidget {
  final Map<String, dynamic>? extra;

  const CommunityScreen({super.key, this.extra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // extra 사용 가능
    if (kDebugMode) {
      print('CommunityScreen extra: $extra');
    }
    //카테고리 상태 구독
    final catState = ref.watch(categoryVMProvider);
    //유저정보
    final uid = extra?['uid'] as String?;
    final location = extra?['dongName'] as String?;
    final hasLocation = location != null && location.isNotEmpty;

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
            //TODO: 바텀네비 투명? 배경 흰색? 정해야함
            // extendBody: true,
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
              //글쓰기 버튼 자리
              onPressed: () {
                if (uid == null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(content: Text('로그인이 필요합니다.')),
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
            // bottomNavigationBar: BottomNav(
            //   mode: BottomNavMode.tab,
            // ),
            bottomNavigationBar: BottomNav(
              mode: BottomNavMode.tab,
              userData: extra, // SplashScreen에서 받아온 Map<String, dynamic>
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
  @override
  void initState() {
    super.initState();

    // 첫 진입 시 초기 데이터 로드
    // Future.microtask(() => ref.read(provider.notifier).loadInitial(ref));
  }

  //게시글마다 댓글갯수 담는곳
  final Map<String, Future<int>> _commentCountFutures = {};
  @override
  Widget build(BuildContext context) {
    if (widget.location == null || widget.location!.isEmpty) {
      return const NoLocationView();
    }
    final provider = communityListVmProvider(
      categoryCode: widget.parentCode,
      detailCode: widget.detailCode,
      location: widget.location!,
    );
    final st = ref.watch(provider);
    // 첫 빌드 때만 초기 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(provider.notifier).loadInitial(ref);
    });
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
                  final date = DateFormat(
                    'yyyy.MM.dd',
                  ).format(x.communityCreateDate);

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
