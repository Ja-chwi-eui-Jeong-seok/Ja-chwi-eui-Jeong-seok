import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/core/utils/xss.dart';
import 'package:ja_chwi/domain/entities/profile_entity.dart';
import 'package:ja_chwi/presentation/providers/profile_providers.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_grid.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_header.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_flow_appbar.dart';
import 'package:go_router/go_router.dart';

final stepProvider = StateProvider<int>((ref) => 0);

/// --------------------
/// 닉네임 입력 위젯
/// --------------------
class NicknameInput extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Future<void> Function(String)? onNext;
  const NicknameInput({
    super.key,
    required this.controller,
    this.onNext,
  });

  @override
  ConsumerState<NicknameInput> createState() => _NicknameInputState();
}

class _NicknameInputState extends ConsumerState<NicknameInput> {
  String? errorText;

  Future<bool> validateAndProceed() async {
    final input = widget.controller.text.trim();
    final sanitized = XssFilter.sanitize(input);

    if (sanitized.isEmpty) {
      setState(() => errorText = "닉네임을 입력해주세요");
      return false;
    }

    final bannedResult = XssFilter.secureInput(sanitized);
    if (bannedResult['hasBannedWord'] == true) {
      setState(() => errorText =
          "사용할 수 없는 단어가 포함되어 있습니다: ${bannedResult['matchedWords'].join(', ')}");
      return false;
    }

    final isDuplicate =
        await ref.read(profileRepositoryProvider).isNicknameDuplicate(input);
    if (isDuplicate) {
      setState(() => errorText = "중복된 닉네임입니다");
      return false;
    }

    if (input.length < 2 || input.length > 8) {
      setState(() => errorText = "닉네임은 2자 이상 8자 이하로 입력해주세요");
      return false;
    }

    setState(() => errorText = null);

    if (widget.onNext != null) {
      await widget.onNext!(sanitized);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final selectedImage = ref.watch(selectedImageProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (selectedImage != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Image.asset(
                  selectedImage.thumbUrl,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '집먼지의 이름을 \n 만들어 주세요..',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'gamjaflower',
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.fromLTRB(5, 0, 0, 10),
          child: Text(
            '닉네임',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: "집먼지의 이름을 지어주세요",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.grey, width: 3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.blue, width: 3),
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

/// --------------------
/// Step 2: 동 검색 + 선택 위젯
/// --------------------
class DongSearchWidget extends StatefulWidget {
  final List<Map<String, String>> dongList;
  final void Function(String) onSelect;
  final String? initialValue;

  const DongSearchWidget({
    super.key,
    required this.dongList,
    required this.onSelect,
    this.initialValue,
  });

  @override
  State<DongSearchWidget> createState() => _DongSearchWidgetState();
}

class _DongSearchWidgetState extends State<DongSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  List<String> searchResults = [];
  String? selected;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
      selected = widget.initialValue;
    }
  }

  void performSearch() {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    final results = <String>[];
    for (var item in widget.dongList) {
      final sido = item['sido']!;
      final sigun = item['sigun']!;
      final fullName = '$sido $sigun';

      // Like 검색
      if (sido.contains(input) || sigun.contains(input) || fullName.contains(input)) {
        results.add(fullName);
      }
    }

    setState(() => searchResults = results);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: "ex) 서울특별시 동작구",
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: performSearch, // 돋보기 클릭
            ),
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => performSearch(),
        ),
        const SizedBox(height: 4),
        if (searchResults.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            itemCount: searchResults.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Colors.grey),
            itemBuilder: (context, index) {
              final item = searchResults[index];
              final isSelected = selected == item;
              return ListTile(
                title: Text(item),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() {
                    selected = item;
                    _controller.text = item;
                    searchResults.clear();
                  });
                  widget.onSelect(item);
                },
              );
            },
          ),
      ],
    );
  }
}

/// --------------------
/// ProfileFlowPage
/// --------------------
class ProfileFlowPage extends ConsumerStatefulWidget {
  final String uid;
  const ProfileFlowPage({super.key, required this.uid, Map<String, dynamic>? extra});

  @override
  ConsumerState<ProfileFlowPage> createState() => _ProfileFlowPageState();
}

class _ProfileFlowPageState extends ConsumerState<ProfileFlowPage> {
  String? dongName;
  String? selectedNickname;
  List<Map<String, String>> dongList = [];

  final GlobalKey<_NicknameInputState> nicknameKey =
      GlobalKey<_NicknameInputState>();

  final TextEditingController nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDongList();
  }

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }

  Future<void> loadDongList() async {
    final jsonStr =
        await rootBundle.loadString('assets/config/json/sido.json');
    final List<dynamic> jsonData = json.decode(jsonStr);
    setState(() {
      dongList = jsonData
          .map((e) => {
                "sido": e['sido'] as String,
                "sigun": e['sigun'] as String,
              })
          .toList();
    });
  }

  Future<void> onNicknameNext(String nickname) async {
    setState(() {
      selectedNickname = nickname;
    });
    ref.read(nicknameProvider.notifier).state = nickname;
    ref.read(stepProvider.notifier).state = 2;
  }

  Future<void> saveProfile() async {
    final nickname = ref.read(nicknameProvider);
    final selectedImage = ref.read(selectedImageProvider);
    final userId = widget.uid;

    if (nickname != null && selectedImage != null && dongName != null) {
      final profile = Profile(
        nickname: nickname,
        imageFullUrl: selectedImage.fullUrl,
        thumbUrl: selectedImage.thumbUrl,
        color: selectedImage.color,
        dongName: dongName!,
        createDate: DateTime.now(),
      );

      await ref.read(profileRepositoryProvider).saveProfile(profile, userId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("프로필 저장 완료")),
      );
      await Future.delayed(const Duration(seconds: 1));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 항목을 선택해주세요")),
      );
    }
  }

  Future<void> onConfirm() async {
    await saveProfile();
    if (!mounted) return;

    final selectedImage = ref.read(selectedImageProvider);
    final nickname = ref.read(nicknameProvider);

    context.push(
      '/guide',
      extra: {
        'uid': widget.uid,
        'nickname': nickname,
        'thumbUrl': selectedImage?.thumbUrl,
        'imageFullUrl': selectedImage?.fullUrl,
        'color': selectedImage?.color,
        'dongName': dongName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(stepProvider);
    final selectedImage = ref.watch(selectedImageProvider);

    return Scaffold(
      appBar: ProfileFlowAppBar(
        step: step,
        onStepBack: () {
          final currentStep = ref.read(stepProvider);
          if (currentStep > 0) {
            ref.read(stepProvider.notifier).state = currentStep - 1;
          } else {
            Navigator.of(context).maybePop();
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: IndexedStack(
          index: step,
          children: [
            // Step 0: 캐릭터 선택
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileHeader(step: 0),
                  const SizedBox(height: 16),
                  const Text(
                    "캐릭터 선택",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const ProfileGrid(),
                ],
              ),
            ),
            // Step 1: 닉네임 입력
            SingleChildScrollView(
              child: NicknameInput(
                key: nicknameKey,
                controller: nicknameController,
                onNext: onNicknameNext,
              ),
            ),
            // Step 2: 동 선택
            SingleChildScrollView(
              child: Column(
                children: [
                  if (selectedImage != null && selectedNickname != null)
                    Column(
                      children: [
                        Image.asset(selectedImage.thumbUrl,
                            width: 60, height: 60),
                        const SizedBox(height: 8),
                        Text(
                          '$selectedNickname의 집은 \n 어디인가요?',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'gamjaflower',
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (dongList.isNotEmpty)
                    DongSearchWidget(
                      dongList: dongList,
                      initialValue: dongName,
                      onSelect: (value) {
                        setState(() {
                          dongName = value;
                        });
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            if (step == 0) {
              if (selectedImage == null) return;
              ref.read(stepProvider.notifier).state = 1;
            } else if (step == 1) {
              final valid = await nicknameKey.currentState?.validateAndProceed();
              if (valid != true) return;
            } else if (step == 2) {
              if (dongName == null) return;
              await onConfirm();
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            side: const BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
          child: Text(
            step == 2 ? "완료" : "다음",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
