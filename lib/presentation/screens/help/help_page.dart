import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/providers/help_provider.dart';
import 'package:ja_chwi/domain/entities/help_entity.dart';

class HelpPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> extra;

  const HelpPage({super.key, required this.extra});

  @override
  ConsumerState<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends ConsumerState<HelpPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";
  HelpEntity? _expandedItem;

  @override
  Widget build(BuildContext context) {
    final helpListAsync = ref.watch(helpListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("도움말"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/settings', extra: widget.extra),
        ),
      ),
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "도움말 검색...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (val) {
                setState(() {
                  _query = val;
                  _expandedItem = null; // 검색 시 확장 초기화
                });
              },
            ),
          ),
          // 리스트
          Expanded(
            child: helpListAsync.when(
              data: (helps) {
                final filtered = helps
                    .where((help) =>
                        help.title.toLowerCase().contains(_query.toLowerCase()))
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("검색 결과가 없습니다."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final help = filtered[index];
                    final isExpanded = _expandedItem == help;

                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Card(
                        elevation: 3,
                        shadowColor: Colors.grey.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            // 리스트 아이템
                            ListTile(
                              title: Text(
                                help.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              trailing: Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: Colors.grey[600],
                              ),
                              onTap: () {
                                setState(() {
                                  _expandedItem =
                                      isExpanded ? null : help;
                                });
                              },
                            ),
                            // 상세 내용
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                color: Colors.grey[50],
                                child: Text(
                                  help.content,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 200),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("에러: $e")),
            ),
          ),
        ],
      ),
    );
  }
}
