import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tutorial_model.dart';

class TutorialDataSource {
  final FirebaseFirestore firestore;

  TutorialDataSource(this.firestore);

  Future<TutorialModel?> fetchTutorial(String accountData) async {
    final doc = await firestore.collection('tutorials').doc(accountData).get();
    if (doc.exists) {
      return TutorialModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> saveTutorial(TutorialModel tutorial) async {
    await firestore
        .collection('tutorials')
        .doc(tutorial.accountData)
        .set(tutorial.toJson());
  }
}
