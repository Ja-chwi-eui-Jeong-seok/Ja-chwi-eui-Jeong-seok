import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/domain/entities/help_entity.dart';
import 'package:ja_chwi/domain/repositories/help_repository.dart';

class HelpRepositoryImpl implements HelpRepository {
  final FirebaseFirestore firestore;
  HelpRepositoryImpl(this.firestore);

  @override
  Stream<List<HelpEntity>> getHelps() {
    return firestore
        .collection('help')
        .where('deleteFlag', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return HelpEntity(
                id: doc.id,
                title: data['title'] ?? '',
                content: data['content'] ?? '',
                createdBy: data['createdBy'] ?? '',
                createdAt: (data['createdAt'] as Timestamp).toDate(),
                updatedBy: data['updatedBy'],
                updatedAt: data['updatedAt'] != null
                    ? (data['updatedAt'] as Timestamp).toDate()
                    : null,
                deletedBy: data['deletedBy'],
                deletedAt: data['deletedAt'] != null
                    ? (data['deletedAt'] as Timestamp).toDate()
                    : null,
                deleteFlag: data['deleteFlag'] ?? false,
              );
            }).toList());
  }

  @override
  Future<void> addHelp(HelpEntity help) async {
    await firestore.collection('help').add({
      'title': help.title,
      'content': help.content,
      'createdBy': help.createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedBy': help.updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
      'deletedBy': null,
      'deletedAt': null,
      'deleteFlag': false,
    });
  }

  @override
  Future<void> updateHelp(HelpEntity help) async {
    await firestore.collection('help').doc(help.id).update({
      'title': help.title,
      'content': help.content,
      'updatedBy': help.updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> softDeleteHelp(String id, String deletedBy) async {
    await firestore.collection('help').doc(id).update({
      'deleteFlag': true,
      'deletedBy': deletedBy,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }
}
