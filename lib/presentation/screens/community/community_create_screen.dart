import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/screens/community/vm/category_vm.dart';

// VM 상태(provider) import
import 'package:ja_chwi/presentation/screens/community/vm/community_create_screen_vm.dart';
// ↑ 내부에서 categoryVMProvider를 외부 공개하고 있어야 함
//   (앞서 만든 CategoryVM, CategoryState 구조 전제)

/// 선택 상태는 파일 상단에 전역 Provider로 둔다.
/// 화면 리빌드 간에도 상태 유지되고, 다른 위젯과 공유 가능.
final selectedCategoryCodeProvider = StateProvider<int?>((_) => null);
final selectedSubCategoryCodeProvider = StateProvider<int?>((_) => null);

class CommunityCreateScreen extends ConsumerStatefulWidget {
  const CommunityCreateScreen({super.key});

  @override
  ConsumerState<CommunityCreateScreen> createState() =>
      _CommunityCreateScreenState();
}

class _CommunityCreateScreenState extends ConsumerState<CommunityCreateScreen> {
  // 화면 제출 로직을 가진 VM (글 등록 등)
  CommunityCreateVm get vm => ref.read(communityCreateVmProvider);

  // 텍스트 입력 컨트롤러
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 카테고리 VM 상태 구독: 상위/하위 목록과 로딩/에러 포함
    final catState = ref.watch(categoryVMProvider);

    // 선택 상태 구독: 선택된 상위코드와 하위이름
    final selectedCode = ref.watch(selectedCategoryCodeProvider);
    final selectedDetailCode = ref.watch(selectedSubCategoryCodeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("글쓰기")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────── 제목/내용 입력 ─────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "제목",
                      hintStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    minLines: 5,
                    maxLines: 10,
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 55,
              child: catState.parents.when(
                // 로딩 표시
                loading: () => const Center(child: CircularProgressIndicator()),
                // 에러 표시
                error: (e, _) => Center(child: Text('오류: $e')),
                // 데이터 렌더링
                data: (parents) => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: parents.map((p) {
                    final isSelected = selectedCode == p.categorycode;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: SizedBox(
                          width: 38,
                          height: 38,
                          child: Center(child: Text(p.categoryname)),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        side: const BorderSide(color: Colors.black),
                        selected: isSelected,
                        onSelected: (_) async {
                          // 같은 칩 재클릭 시 해제
                          final next = isSelected ? null : p.categorycode;
                          ref
                                  .read(selectedCategoryCodeProvider.notifier)
                                  .state =
                              next;
                          // 하위 선택 초기화
                          ref
                                  .read(
                                    selectedSubCategoryCodeProvider.notifier,
                                  )
                                  .state =
                              null;
                          // 선택되면 하위 목록 로드 (메모이징 포함)
                          if (next != null) {
                            await ref
                                .read(categoryVMProvider.notifier)
                                .loadChildren(next);
                          }
                        },
                        selectedColor: Colors.black,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                              selectedDetailCode == s.categorydetailcode;
                          return ChoiceChip(
                            label: SizedBox(
                              height: 20,
                              child: Text(s.categorydetailname),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            side: const BorderSide(color: Colors.black),
                            selected: isSelected,
                            onSelected: (_) {
                              ref
                                  .read(
                                    selectedSubCategoryCodeProvider.notifier,
                                  )
                                  .state = isSelected
                                  ? null
                                  : s.categorydetailcode;
                            },
                            selectedColor: Colors.black,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
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
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 50),
              child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () async {
                    // 선택값 읽기
                    final code = ref.read(selectedCategoryCodeProvider);
                    final subCode = ref.read(selectedSubCategoryCodeProvider);

                    // 디버그 출력
                    debugPrint("제목: ${_titleController.text}");
                    debugPrint("내용: ${_contentController.text}");
                    debugPrint("상위코드: $code");
                    debugPrint("하위코드: $subCode");

                    // 서버 제출: VM에 위임
                    final err = await vm.submit(
                      title: _titleController.text,
                      content: _contentController.text,
                      category: code,
                      subCategory: subCode,
                    );

                    if (!context.mounted) return;
                    if (err == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('등록완료')),
                      );
                      // TODO: 상세 화면 이동 등
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err)),
                      );
                    }
                  },
                  child: Container(
                    width: 300,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Center(
                      child: Text(
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
          ],
        ),
      ),
    );
  }
}
