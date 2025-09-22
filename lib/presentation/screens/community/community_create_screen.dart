import 'package:flutter/material.dart';

class CommunityCreateScreen extends StatefulWidget {
  const CommunityCreateScreen({super.key});

  @override
  State<CommunityCreateScreen> createState() => _CommunityCreateScreenState();
}

class _CommunityCreateScreenState extends State<CommunityCreateScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // 선택된 카테고리
  String? selectedCategory;
  String? selectedSubCategory;

  // 카테고리별 세부 카테고리 매핑
  final Map<String, List<String>> subCategories = {
    '요리': ['한식', '양식', '디저트', '자유'],
    '운동': ['크로스핏', '스트릿', '헬스', '스포츠', '자유'],
    '청소': ['방청소', '주방청소', '욕실청소', '자유'],
    '미션': ['일상미션', '챌린지', '자유'],
    '자유': ['잡담', '정보공유', '자유'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("글쓰기")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 입력
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "제목",
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

            // 카테고리 선택
            Text(
              "카테고리를 정해주세요.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            //Center로 가운데 정렬하고 SizedBox로 크기제한,Wrap의 자동줄바꿈 가능하게만듦
            Center(
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: ['자유', '운동', '청소', '미션', '요리']
                      .map(
                        (c) => ChoiceChip(
                          label: SizedBox(
                            width: 38,
                            height: 38,
                            child: Center(child: Text(c)),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(15),
                          ),
                          side: BorderSide(color: Colors.black),
                          selected: selectedCategory == c,
                          onSelected: (_) {
                            setState(() {
                              selectedCategory = c;
                              selectedSubCategory = null; // 초기화
                            });
                          },
                          selectedColor: Colors.black,
                          labelStyle: TextStyle(
                            color: selectedCategory == c
                                ? Colors.white
                                : Colors.black,
                          ),
                          backgroundColor: Colors.white,
                          showCheckmark: false,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 세부 카테고리 선택
            Center(
              child: const Text(
                "세부 카테고리를 정해주세요.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            if (selectedCategory != null) ...[
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  //runAlignment: WrapAlignment.center,
                  //crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: subCategories[selectedCategory]!
                      .map(
                        (sub) => ChoiceChip(
                          label: SizedBox(height: 20, child: Text(sub)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(15),
                          ),
                          side: BorderSide(color: Colors.black),
                          selected: selectedSubCategory == sub,
                          onSelected: (_) {
                            setState(() {
                              selectedSubCategory = sub;
                            });
                          },
                          selectedColor: Colors.black,
                          labelStyle: TextStyle(
                            color: selectedSubCategory == sub
                                ? Colors.white
                                : Colors.black,
                          ),
                          backgroundColor: Colors.white,
                          showCheckmark: false,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            //selectedSubCategory = sub
            const SizedBox(height: 32),

            // 확인 버튼
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  print("제목: ${_titleController.text}");
                  print("내용: ${_contentController.text}");
                  print("카테고리: $selectedCategory");
                  print("세부 카테고리: $selectedSubCategory");
                },
                child: Container(
                  width: 300,
                  height: 55,
                  decoration: BoxDecoration(
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
          ],
        ),
      ),
    );
  }
}
