import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

///Firestore 로직 전담 서비스
class CategoryService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// 카테고리 스트림
  Stream<List<Map<String, dynamic>>> getCategories() {
    return firestore
        .collection('categorycode')
        .where('category_delete_yn', isEqualTo: false)
        .orderBy('category_code')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'docId': doc.id,
              'categoryCode': data['category_code'] ?? 0,
              'categoryName': data['category_name'] ?? '',
            };
          }).toList(),
        );
  }

  /// 상세 코드 스트림
  Stream<List<Map<String, dynamic>>> getCategoryDetails(num categoryCode) {
    return firestore
        .collection('categorydetail')
        .where('category_code', isEqualTo: categoryCode)
        .where('category_delete_yn', isEqualTo: false)
        .orderBy('category_detail_code')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'docId': doc.id,
              'detailCode': data['category_detail_code'] ?? 0,
              'detailName': data['category_detail_name'] ?? '',
            };
          }).toList(),
        );
  }

  ///중복 코드 검사
  Future<bool> isDuplicate({
    required bool isCategory,
    required num code,
    num? parentCode,
    String? excludeDocId,
  }) async {
    final collection = isCategory ? 'categorycode' : 'categorydetail';
    Query query = firestore.collection(collection);

    if (isCategory) {
      query = query.where('category_code', isEqualTo: code);
    } else {
      query = query
          .where('category_code', isEqualTo: parentCode)
          .where('category_detail_code', isEqualTo: code);
    }

    query = query.where('category_delete_yn', isEqualTo: false).limit(1);
    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) return false;
    return snapshot.docs.first.id != excludeDocId;
  }

  ///신규 추가 / 수정
  Future<void> saveCategory({
    required bool isCategory,
    required num code,
    required String name,
    num? parentCategoryCode,
    String? docId,
  }) async {
    final collection = isCategory ? 'categorycode' : 'categorydetail';
    final data = <String, dynamic>{
      if (isCategory)
        'category_code': code
      else ...{
        'category_code': parentCategoryCode,
        'category_detail_code': code,
      },
      if (isCategory) 'category_name': name else 'category_detail_name': name,
    };

    if (docId == null) {
      // 신규 등록
      data.addAll({
        'category_create': Timestamp.now(),
        'category_update': null,
        'category_delete_yn': false,
        'category_delete_note': null,
        'category_delete_date': null,
      });
      await firestore.collection(collection).add(data);
    } else {
      // 수정
      data['category_update'] = Timestamp.now();
      await firestore.collection(collection).doc(docId).update(data);
    }
  }

  Future<void> deleteCategory(
    String collection,
    String docId,
    String note,
  ) async {
    await firestore.collection(collection).doc(docId).update({
      'category_delete_yn': true,
      'category_delete_note': note.trim(),
      'category_delete_date': Timestamp.now(),
    });
  }
}

/// 추가/수정 다이얼로그 위젯
class AddOrEditDialog extends StatefulWidget {
  final bool isCategory;
  final num? parentCategoryCode;
  final num? currentCode;
  final String? currentName;
  final String? docId;
  final CategoryService service;

  const AddOrEditDialog({
    super.key,
    required this.service,
    this.isCategory = false,
    this.parentCategoryCode,
    this.currentCode,
    this.currentName,
    this.docId,
  });

  @override
  State<AddOrEditDialog> createState() => _AddOrEditDialogState();
}

class _AddOrEditDialogState extends State<AddOrEditDialog> {
  late final TextEditingController codeController;
  late final TextEditingController nameController;
  final FocusNode codeFocus = FocusNode();
  final FocusNode nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController(
      text: widget.currentCode?.toString() ?? '',
    );
    nameController = TextEditingController(text: widget.currentName ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusScope.of(context).requestFocus(codeFocus);
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    nameController.dispose();
    codeFocus.dispose();
    nameFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus(); // 키보드 이벤트 정리

    final codeText = codeController.text.trim();
    final nameText = nameController.text.trim();

    if (codeText.isEmpty || nameText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('코드와 이름을 모두 입력해주세요.')));
      return;
    }

    final codeNum = num.tryParse(codeText);
    if (codeNum == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('코드는 숫자만 입력 가능합니다.')));
      return;
    }

    final isDup = await widget.service.isDuplicate(
      isCategory: widget.isCategory,
      code: codeNum,
      parentCode: widget.parentCategoryCode,
      excludeDocId: widget.docId,
    );

    if (isDup) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미 존재하는 코드입니다.')));
      return;
    }

    await widget.service.saveCategory(
      isCategory: widget.isCategory,
      code: codeNum,
      name: nameText,
      parentCategoryCode: widget.parentCategoryCode,
      docId: widget.docId,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.docId == null ? '추가' : '수정'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: codeController,
            focusNode: codeFocus,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: '코드'),
            onEditingComplete: () =>
                FocusScope.of(context).requestFocus(nameFocus),
          ),
          TextField(
            controller: nameController,
            focusNode: nameFocus,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: '이름'),
            onEditingComplete: () => FocusScope.of(context).unfocus(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus(); //키보드 해제
            Navigator.pop(context);
          },
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: _handleSave,
          child: Text(widget.docId == null ? '추가' : '저장'),
        ),
      ],
    );
  }
}

///메인 페이지 (UI 중심, 로직은 얇게)
class CategoryPage extends StatelessWidget {
  final Map<String, dynamic> extra;
  final CategoryService service = CategoryService();

  CategoryPage({super.key, required this.extra});

  void _showAddOrEditDialog(
    BuildContext context, {
    bool isCategory = false,
    num? parentCategoryCode,
    num? currentCode,
    String? currentName,
    String? docId,
  }) {
    showDialog(
      context: context,
      builder: (_) => AddOrEditDialog(
        service: service,
        isCategory: isCategory,
        parentCategoryCode: parentCategoryCode,
        currentCode: currentCode,
        currentName: currentName,
        docId: docId,
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    String docId,
    String collection,
  ) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제 확인'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(labelText: '삭제 사유'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              FocusScope.of(context).unfocus(); //키보드 정리
              Navigator.pop(context);
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              FocusScope.of(context).unfocus(); // 키보드 정리
              await service.deleteCategory(
                collection,
                docId,
                noteController.text,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리 관리'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.go('/admin', extra: extra);
          },
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.getCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final categories = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final c = categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ExpansionTile(
                  title: Text('${c['categoryName']} (${c['categoryCode']})'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAddOrEditDialog(
                          context,
                          isCategory: true,
                          currentCode: c['categoryCode'],
                          currentName: c['categoryName'],
                          docId: c['docId'],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteDialog(
                          context,
                          c['docId'],
                          'categorycode',
                        ),
                      ),
                    ],
                  ),
                  children: [
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: service.getCategoryDetails(c['categoryCode']),
                      builder: (context, detailSnapshot) {
                        final details = detailSnapshot.data ?? [];
                        return Column(
                          children: [
                            ...details.map(
                              (d) => ListTile(
                                title: Text(
                                  '${d['detailName']} (${d['detailCode']})',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showAddOrEditDialog(
                                        context,
                                        parentCategoryCode: c['categoryCode'],
                                        currentCode: d['detailCode'],
                                        currentName: d['detailName'],
                                        docId: d['docId'],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _showDeleteDialog(
                                        context,
                                        d['docId'],
                                        'categorydetail',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.add),
                              title: const Text('상세 코드 추가'),
                              onTap: () => _showAddOrEditDialog(
                                context,
                                parentCategoryCode: c['categoryCode'],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditDialog(context, isCategory: true),
        child: const Icon(Icons.add),
      ),
    );
  }
}
