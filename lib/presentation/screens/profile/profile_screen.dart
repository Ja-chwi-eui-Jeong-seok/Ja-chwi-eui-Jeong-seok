import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/core/utils/xss.dart';
import 'package:ja_chwi/domain/entities/profile_entity.dart';
import 'package:ja_chwi/presentation/providers/profile_providers.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_grid.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;
  const ProfileScreen({super.key, required this.extra});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController dongController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  List<Map<String, String>> dongList = [];
  List<Map<String, String>> searchResults = [];
  bool isSearching = false;

  bool isLoading = true;
  bool isSaving = false;
  String? uid;

  @override
  void initState() {
    super.initState();
    uid = widget.extra?['uid'];
    if (uid == null) {
      debugPrint('⚠️ ProfileScreen: extra에서 uid를 찾을 수 없습니다.');
    }
    _initialize();
  }

  Future<void> _initialize() async {
    await loadDongList();
    await loadProfile();
  }

  Future<void> loadDongList() async {
    final jsonStr = await rootBundle.loadString('assets/config/json/sido.json');
    final List<dynamic> jsonData = json.decode(jsonStr);
    dongList = jsonData
        .map((e) => {"sido": e['sido'] as String, "sigun": e['sigun'] as String})
        .toList();
  }

  Future<void> loadProfile() async {
    if (uid == null) return;
    final repo = ref.read(profileRepositoryProvider);
    final profile = await repo.getProfileByUid(uid!);
    if (profile != null) {
      nicknameController.text = profile.nickname;
      dongController.text = profile.dongName;
      ref.read(selectedImageProvider.notifier).state = ProfileImage(
        id: 'loaded',
        thumbUrl: profile.thumbUrl,
        fullUrl: profile.imageFullUrl,
        color: profile.color,
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> saveProfile() async {
    if (uid == null) return;

    final nickname = nicknameController.text.trim();
    final dongName = dongController.text.trim();
    final selectedImage = ref.read(selectedImageProvider);

    if (nickname.isEmpty || dongName.isEmpty || selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 항목을 입력해주세요")),
      );
      return;
    }

    // ✅ XSS 및 금지어 검사
    final sanitized = XssFilter.sanitize(nickname);
    final banned = XssFilter.secureInput(sanitized);
    if (banned['hasBannedWord'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("금지어 포함: ${banned['matchedWords'].join(', ')}")),
      );
      return;
    }

    setState(() => isSaving = true);
    final repo = ref.read(profileRepositoryProvider);

    final profile = Profile(
      nickname: sanitized,
      imageFullUrl: selectedImage.fullUrl,
      thumbUrl: selectedImage.thumbUrl,
      color: selectedImage.color,
      dongName: dongName,
      createDate: DateTime.now(),
    );

    await repo.saveProfile(profile, uid!);
    if (!mounted) return;

    setState(() => isSaving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("프로필이 저장되었습니다")));

    // ✅ 수정된 데이터 포함하여 /profile-detail 로 이동
    context.go(
      '/profile-detail',
      extra: {
        'uid': uid,
        'nickname': nicknameController.text.trim(),
        'dongName': dongController.text.trim(),
        'thumbUrl': selectedImage.thumbUrl,
        'imageFullUrl': selectedImage.fullUrl,
        'color': selectedImage.color,
      },
    );
  }

  void searchDong(String input) {
    input = input.trim();
    if (input.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults = [];
      });
      return;
    }

    final results = dongList
        .where((e) =>
            e['sido']!.contains(input) ||
            e['sigun']!.contains(input) ||
            '${e['sido']} ${e['sigun']}'.contains(input))
        .toList();

    setState(() {
      isSearching = true;
      searchResults = results;
    });
  }

  void selectDong(String fullName) {
    FocusScope.of(context).unfocus(); // 키보드 닫기
    dongController.text = fullName;
    setState(() {
      isSearching = false;
      searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedImage = ref.watch(selectedImageProvider);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("프로필 수정"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/profile-detail', extra: widget.extra),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;

          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: availableHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: selectedImage != null && selectedImage.fullUrl.isNotEmpty
                        ? Image.asset(
                            selectedImage.fullUrl,
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.width * 0.5,
                            fit: BoxFit.contain,
                          )
                        : const Icon(Icons.person, size: 100, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // 닉네임 입력
                  TextField(
                    controller: nicknameController,
                    decoration: InputDecoration(
                      labelText: "닉네임",
                      hintText: "닉네임을 입력하세요",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 우리 동네 입력 + 실시간 검색
                  TextField(
                    controller: dongController,
                    onChanged: searchDong,
                    decoration: InputDecoration(
                      labelText: "우리 동네",
                      hintText: "ex) 서울특별시 동작구",
                      suffixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // ✅ 검색 결과 리스트 (저장버튼 위까지만)
                  if (isSearching && searchResults.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: availableHeight * 0.3,
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (_, index) {
                          final r = searchResults[index];
                          final fullName = '${r['sido']} ${r['sigun']}';
                          return ListTile(
                            title: Text(fullName),
                            onTap: () => selectDong(fullName),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  const ProfileGrid(),
                  const SizedBox(height: 16),

                  // 저장 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : saveProfile,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("저장", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}