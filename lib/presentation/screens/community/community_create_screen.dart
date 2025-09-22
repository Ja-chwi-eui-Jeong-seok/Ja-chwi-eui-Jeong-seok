import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/community_create_screen_vm.dart';

class CommunityCreateScreen extends ConsumerStatefulWidget {
  const CommunityCreateScreen({super.key});

  @override
  ConsumerState<CommunityCreateScreen> createState() =>
      _CommunityCreateScreenState();
}

class _CommunityCreateScreenState extends ConsumerState<CommunityCreateScreen> {
  CommunityCreateVm get vm => ref.read(communityCreateVmProvider);
  final selectedCategoryProvider = StateProvider<String?>((ref) => null);
  final selectedSubCategoryProvider = StateProvider<String?>((ref) => null);

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // 선택된 카테고리
  String? selectedCategory;
  String? selectedSubCategory;

  // 카테고리별 세부 카테고리 매핑
  final Map<String, List<String>> subCategories = {
    //카테고리 불러오고 , 서브카테고리 맵핑하기
    '요리': ['한식', '양식', '디저트', '자유'],
    '운동': ['크로스핏', '스트릿', '헬스', '스포츠', '자유'],
    '청소': ['방청소', '주방청소', '욕실청소', '자유'],
    '미션': ['일상미션', '챌린지', '자유'],
    '자유': ['잡담', '정보공유', '자유'],
  };

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedSubCategory = ref.watch(selectedSubCategoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("글쓰기")),
      body: SingleChildScrollView(
        //padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 입력
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

                  // 내용 입력
                  TextFormField(
                    controller: _contentController,
                    minLines: 5,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: "게시글을 작성해주세요!",
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
            Divider(
              height: 2,
              thickness: 2,
            ),
            // 카테고리 선택
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                "카테고리를 정해주세요.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(
              height: 55, // 칩 높이 + 여백
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children:
                    [
                          '자유',
                          '운동',
                          '청소',
                          '미션',
                          '요리',
                        ] //TODO:만들어진 리스트의 카테고리코드 불러오고 리스트로 만들기
                        .map((mainCategory) {
                          final isSelected = selectedCategory == mainCategory;
                          return Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: SizedBox(
                                width: 38,
                                height: 38,
                                child: Center(child: Text(mainCategory)),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15), // ✅ 수정
                              ),
                              side: const BorderSide(color: Colors.black),
                              selected: selectedCategory == mainCategory,
                              onSelected: (_) {
                                ref
                                    .read(selectedCategoryProvider.notifier)
                                    .state = isSelected
                                    ? null
                                    : mainCategory; // 같은 칩 누르면 해제 옵션
                                ref
                                        .read(
                                          selectedSubCategoryProvider.notifier,
                                        )
                                        .state =
                                    null;
                              },
                              selectedColor: Colors.black,
                              labelStyle: TextStyle(
                                color: selectedCategory == mainCategory
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              backgroundColor: Colors.white,
                              showCheckmark: false,
                            ),
                          );
                        })
                        .toList(),
              ),
            ),

            SizedBox(height: 30),
            Divider(
              height: 2,
              thickness: 2,
            ),

            // 세부 카테고리 선택
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                "세부 카테고리를 정해주세요.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            if (selectedCategory != null) ...[
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: (subCategories[selectedCategory] ?? []).map((
                    subCategory,
                  ) {
                    final isSelected = selectedSubCategory == subCategory;
                    return ChoiceChip(
                      label: SizedBox(height: 20, child: Text(subCategory)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(15),
                      ),
                      side: BorderSide(color: Colors.black),
                      selected: selectedSubCategory == subCategory,
                      onSelected: (_) {
                        ref.read(selectedSubCategoryProvider.notifier).state =
                            isSelected ? null : subCategory;
                      },
                      selectedColor: Colors.black,
                      labelStyle: TextStyle(
                        color: selectedSubCategory == subCategory
                            ? Colors.white
                            : Colors.black,
                      ),
                      backgroundColor: Colors.white,
                      showCheckmark: false,
                    );
                  }).toList(),
                ),
              ),
            ],
            SizedBox(height: 32),
            Divider(
              height: 2,
              thickness: 2,
            ),
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 50),
              child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () async {
                    //테스트용 프린트
                    print("제목: ${_titleController.text}");
                    print("내용: ${_contentController.text}");
                    print("카테고리: $selectedCategory");
                    print("세부 카테고리: $selectedSubCategory");

                    //유효성검증
                    final err = await vm.submit(
                      title: _titleController.text,
                      content: _contentController.text,
                      category: selectedCategory,
                      subCategory: selectedSubCategory,
                    );

                    if (!context.mounted) return;
                    if (err == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('등록완료'),
                        ),
                      );
                      //TODO: 로딩 후 작성글한 글로 이동
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(err),
                        ),
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
                    child: Center(
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
