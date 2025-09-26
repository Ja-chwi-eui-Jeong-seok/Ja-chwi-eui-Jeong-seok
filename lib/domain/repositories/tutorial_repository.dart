import '../entities/tutorial_entity.dart';

abstract class TutorialRepository {
  Future<TutorialEntity?> getTutorial(String accountData);
  Future<void> saveTutorial(TutorialEntity tutorial);
}
