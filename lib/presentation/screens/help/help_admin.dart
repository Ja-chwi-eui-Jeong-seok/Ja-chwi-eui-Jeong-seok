import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/providers/help_provider.dart';
import 'package:ja_chwi/presentation/screens/help/help_detail.dart';

class HelpAdminPage extends ConsumerWidget {
  final Map<String, dynamic>? extra;
  const HelpAdminPage({super.key, this.extra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final helpListAsync = ref.watch(helpListProvider);

    // extra에서 uid 가져오기
    final currentUserId = extra?['uid'] as String? ?? 'adminUid';

    return Scaffold(
      appBar: AppBar(
        title: const Text("도움말 관리"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.go('/admin', extra: extra);
          },
        ),
      ),
      body: helpListAsync.when(
        data: (helps) {
          return ListView.builder(
            itemCount: helps.length,
            itemBuilder: (context, index) {
              final help = helps[index];
              return Card(
                child: ListTile(
                  title: Text(help.title),
                  subtitle: Text(
                    help.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HelpDetailPage(
                                help: help,
                                extra: extra, // extra 전달
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final repo = ref.read(helpRepositoryProvider);
                          await repo.softDeleteHelp(help.id, currentUserId);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        //error: (e, _) => Center(child: Text("에러: $e")),
        error: (e, stack) {
          // 콘솔에 에러 출력
          debugPrint('도움말 로딩 에러: $e\n$stack');

          // 화면에는 간단히 메시지 표시
          return const Center(child: Text("도움말 로딩 중 오류 발생"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HelpDetailPage(extra: extra),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
