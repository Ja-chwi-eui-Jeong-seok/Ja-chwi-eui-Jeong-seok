import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/core/utils/xss.dart';
import 'package:ja_chwi/presentation/providers/user_profile_by_uid_provider.dart.dart';
import 'package:ja_chwi/presentation/screens/community/vm/category_vm.dart';

// VM 상태(provider) import
import 'package:ja_chwi/presentation/screens/community/vm/community_create_vm.dart';
import 'package:ja_chwi/presentation/screens/community/vm/community_list_vm.dart';
// ↑ 내부에서 categoryVMProvider를 외부 공개하고 있어야 함
//   (앞서 만든 CategoryVM, CategoryState 구조 전제)

/// 선택 상태는 파일 상단에 전역 Provider로 둔다.
/// 화면 리빌드 간에도 상태 유지되고, 다른 위젯과 공유 가능.
final selectedCategoryCodeProvider = StateProvider<int?>((_) => null);
final selectedSubCategoryCodeProvider = StateProvider<int?>((_) => null);

class CommunityCreateScreen extends ConsumerStatefulWidget {
  const CommunityCreateScreen({super.key, this.id});
  final String? id;

  @override
  ConsumerState<CommunityCreateScreen> createState() =>
      _CommunityCreateScreenState();
}

class _CommunityCreateScreenState extends ConsumerState<CommunityCreateScreen> {
  // 화면 제출 로직을 가진 VM (글 등록 등)
  //CommunityCreateVm get vm => ref.read(communityCreateVmProvider);

  // 텍스트 입력 컨트롤러
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  //금지어 적용하기위한 폼키
  final _formKey = GlobalKey<FormState>();
  //텍스트필드 초기포커스용
  final f1 = FocusNode();
  late final CommunityCreateVm vm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => f1.requestFocus());
    vm = ref.read(communityCreateVmProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.id; // 라우터에서 전달받은 문서 id
      if (id == null) {
        vm.setModeCreate();
      } else {
        vm.setModeEdit(id);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    f1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.id != null;
    final st = ref.watch(communityCreateVmProvider);

    // ← build 안에서 listen
    ref.listen<CommunityCreateVm>(communityCreateVmProvider, (prev, next) {
      if (next.isEdit && !next.loading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_titleController.text != next.title) {
            _titleController.text = next.title;
          }
          if (_contentController.text != next.content) {
            _contentController.text = next.content;
          }
          ref.read(selectedCategoryCodeProvider.notifier).state =
              next.categoryCode;
          ref.read(selectedSubCategoryCodeProvider.notifier).state =
              next.categoryDetailCode;
        });
      }
    });

    // 생성 화면: 기존처럼 extra에서 uid
    // 수정 화면: 파이어베이스에서 현재 로그인 uid 사용
    final uid =
        FirebaseAuth.instance.currentUser?.uid ??
        (GoRouterState.of(context).extra as String?);
    final appBarTitle = isEdit ? '글 수정' : '글쓰기';
    // 카테고리 VM 상태 구독: 상위/하위 목록과 로딩/에러 포함
    final catState = ref.watch(categoryVMProvider);
    //글작성상태 구독
    final submitState = ref.watch(communityCreateVmProvider).submitting;

    // 선택 상태 구독: 선택된 상위코드와 하위이름
    final selectedCode = ref.watch(selectedCategoryCodeProvider);
    final selectedDetailCode = ref.watch(selectedSubCategoryCodeProvider);

    //uid없을때 뱉기
    if (uid == null) {
      return Scaffold(
        body: Center(
          child: Text('잘못된 접근입니다.(회원정보 없음)'),
        ),
      );
    }
    //uid 기반 프로필정보 로드(유저정보,위치정보)
    final profileAv = ref.watch(profileByUidProvider(uid));

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: st.loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ───────── 제목/내용 입력 ─────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // 위치 표시
                          profileAv.when(
                            loading: () => const Text('위치 불러오는 중...'),
                            error: (e, _) => Text('위치 오류: $e'),
                            data: (g) => Text(
                              '현재 위치: ${g.dongName}',
                            ),
                          ),
                          TextFormField(
                            controller: _titleController,
                            onChanged: (v) => ref
                                .read(communityCreateVmProvider)
                                .setDraft(title: v),
                            //초기포커스
                            focusNode: f1,
                            textInputAction: TextInputAction.next,
                            //금지어검사
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) return null;
                              final r = XssFilter.secureInput(value);
                              if (r['hasBannedWord'] == true) {
                                final words = (r['matchedWords'] as List).join(
                                  ', ',
                                );
                                return '금지어가 포함되었습니다. 금지어 : $words';
                              }
                              return null;
                            },
                            maxLength: 50,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "제목",
                              hintStyle: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              //카운터삭제
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _contentController,
                            onChanged: (v) => ref
                                .read(communityCreateVmProvider)
                                .setDraft(content: v),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) return null;
                              final r = XssFilter.secureInput(value);
                              if (r['hasBannedWord'] == true) {
                                final words = (r['matchedWords'] as List).join(
                                  ', ',
                                );
                                return '금지어가 포함되었습니다. 금지어 : $words';
                              }
                              return null;
                            },
                            minLines: 5,
                            maxLines: 10,
                            maxLength: 500,

                            decoration: const InputDecoration(
                              hintText: "게시글을 작성해주세요!",
                              border: InputBorder.none,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    const Divider(height: 2, thickness: 2),

                    // ───────── 상위 카테고리 선택(동적) ─────────
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        "카테고리를 정해주세요.",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 55,
                      child: catState.parents.when(
                        // 로딩 표시
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        // 에러 표시
                        error: (e, _) => Center(child: Text('오류: $e')),
                        // 데이터 렌더링
                        data: (parents) => ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: parents.map((p) {
                            final isSelected = selectedCode == p.categoryCode;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ChoiceChip(
                                label: SizedBox(
                                  width: 38,
                                  height: 38,
                                  child: Center(child: Text(p.categoryName)),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                side: const BorderSide(color: Colors.black),
                                selected: isSelected,
                                onSelected: (_) async {
                                  final next = isSelected
                                      ? null
                                      : p.categoryCode;
                                  ref
                                      .read(communityCreateVmProvider)
                                      .setDraft(categoryCode: next);
                                  ref
                                          .read(
                                            selectedCategoryCodeProvider
                                                .notifier,
                                          )
                                          .state =
                                      next;
                                  ref
                                          .read(
                                            selectedSubCategoryCodeProvider
                                                .notifier,
                                          )
                                          .state =
                                      null;
                                  if (next != null) {
                                    await ref
                                        .read(categoryVMProvider.notifier)
                                        .loadChildren(next);
                                  }
                                },
                                selectedColor: Colors.black,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                backgroundColor: Colors.white,
                                showCheckmark: false,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Divider(height: 2, thickness: 2),

                    // ───────── 하위 카테고리 선택(동적) ─────────
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        "세부 카테고리를 정해주세요.",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (selectedCode != null) ...[
                      // children 맵에서 선택된 code의 AsyncValue를 꺼내고 상태별로 렌더링
                      Builder(
                        builder: (_) {
                          final av = catState.children[selectedCode];
                          if (av == null || av.isLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return av.when(
                            loading: () => const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (e, _) => Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('오류: $e'),
                            ),
                            data: (subs) => SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                children: subs.map((s) {
                                  final isSelected =
                                      selectedDetailCode ==
                                      s.categoryDetailCode;
                                  return ChoiceChip(
                                    label: SizedBox(
                                      height: 20,
                                      child: Text(s.categoryDetailName),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    side: const BorderSide(color: Colors.black),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      final next = isSelected
                                          ? null
                                          : s.categoryDetailCode;
                                      ref
                                          .read(communityCreateVmProvider)
                                          .setDraft(categoryDetailCode: next);
                                      ref
                                              .read(
                                                selectedSubCategoryCodeProvider
                                                    .notifier,
                                              )
                                              .state =
                                          next;
                                    },
                                    selectedColor: Colors.black,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    backgroundColor: Colors.white,
                                    showCheckmark: false,
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 32),
                    const Divider(height: 2, thickness: 2),
                    const SizedBox(height: 32),

                    // ───────── 제출 버튼 ─────────
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: 50,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: AbsorbPointer(
                          // 제출 중 탭 막기
                          absorbing: submitState,
                          child: GestureDetector(
                            onTap: () async {
                              // 프로필(위치) 먼저 확보
                              final profile = ref
                                  .read(profileByUidProvider(uid))
                                  .maybeWhen(
                                    data: (p) => p,
                                    orElse: () => null,
                                  );
                              if (profile == null || profile.dongName.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '작성자/위치 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              // // 1) 금지어 폼 검증
                              if (!_formKey.currentState!.validate()) return;

                              // 2) 정화
                              final titleR = XssFilter.secureInput(
                                _titleController.text.trim(),
                              );
                              final bodyR = XssFilter.secureInput(
                                _contentController.text.trim(),
                              );
                              final title = titleR['sanitized'] as String;
                              final body = bodyR['sanitized'] as String;

                              // 4) 변경되었으면 안내(선택)
                              if (title != _titleController.text ||
                                  body != _contentController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('안전하지 않은 문자가 제거되었습니다.'),
                                  ),
                                );
                              }

                              final vmState = ref.read(
                                communityCreateVmProvider,
                              );
                              //수정분기
                              if (vmState.isEdit) {
                                final err = await vmState.update(
                                  title: _titleController.text,
                                  content: _contentController.text,
                                  categoryCode: vmState.categoryCode,
                                  subCategoryCode: vmState.categoryDetailCode,
                                );
                                if (!context.mounted) return;
                                if (err != null) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text(err)));
                                  return;
                                }
                                if (!context.mounted) return;
                                // 1) 편집 화면 닫기 -> 스택의 맨 위(Edit) 제거
                                context.pop();

                                // 2) 바로 다음 프레임에 '예전 상세'를 '새 상세'로 교체
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  context.pushReplacement(
                                    '/community-detail',
                                    extra: vmState.postId,
                                  );
                                });
                                //게시글 리스트 초기화
                                ref
                                    .read(communityChangedTickProvider.notifier)
                                    .state++;

                                //생성분기
                              } else {
                                final res = await vmState.submit(
                                  title: _titleController.text,
                                  content: _contentController.text,
                                  categoryCode: vmState.categoryCode,
                                  subCategoryCode: vmState.categoryDetailCode,
                                  createUser: uid,
                                  location: profile.dongName,
                                );
                                //게시글 리스트 초기화
                                ref
                                    .read(communityChangedTickProvider.notifier)
                                    .state++;

                                // 성공 후 다시 작성하러 돌아왔다면 선택칩도 비워주기
                                ref
                                        .read(
                                          selectedCategoryCodeProvider.notifier,
                                        )
                                        .state =
                                    null;
                                ref
                                        .read(
                                          selectedSubCategoryCodeProvider
                                              .notifier,
                                        )
                                        .state =
                                    null;
                                if (!context.mounted) return;
                                if (res.error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(res.error!)),
                                  );
                                  return;
                                }

                                //'예전 상세'를 '새 상세'로 교체
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  context.pushReplacement(
                                    '/community-detail',
                                    extra: res.newId,
                                  );
                                });
                              }
                            },
                            child: Opacity(
                              opacity: submitState ? 0.6 : 1,
                              child: Container(
                                width: 300,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Center(
                                  child: submitState
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          "확인",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
