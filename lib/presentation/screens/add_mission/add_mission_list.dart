import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'add_mission_form.dart';
import 'edit_mission_form.dart';
import 'package:ja_chwi/presentation/providers/add_mission_providers.dart';

class AddMissionList extends ConsumerWidget {
  final Map<String, dynamic> extra;

  const AddMissionList({
    super.key,
    required this.extra,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsAsync = ref.watch(addMissionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('미션 등록/수정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/admin', extra: extra),
        ),
      ),
      body: missionsAsync.when(
        data: (missions) {
          if (missions.isEmpty) {
            return const Center(child: Text('등록된 미션이 없습니다.'));
          }

          return ListView.builder(
            itemCount: missions.length,
            itemBuilder: (context, index) {
              final m = missions[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Dismissible(
                  key: Key(m.id!),
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) async {
                    await ref.read(addMissionRepositoryProvider).deleteMission(m.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('미션이 삭제되었습니다.')),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Dismissible(
                      key: Key(m.id!),
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) async {
                        await ref.read(addMissionRepositoryProvider).deleteMission(m.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('미션이 삭제되었습니다.')),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300), // 카드 라인
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: ListTile(
                          title: Text(
                            '${m.missionCode}. ${m.missionTitle}', // missionCode + 제목
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('#${m.missionTag}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditMissionForm(mission: m),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMissionForm()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
