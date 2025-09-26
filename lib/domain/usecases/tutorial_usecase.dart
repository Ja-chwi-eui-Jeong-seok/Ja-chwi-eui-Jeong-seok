import '../entities/tutorial_entity.dart';
import '../repositories/tutorial_repository.dart';

class TutorialUseCase {
  final TutorialRepository repository;

  TutorialUseCase(this.repository);

  Future<TutorialEntity?> checkTutorialStatus(String accountData) async {
    return await repository.getTutorial(accountData);
  }

  Future<void> completeTutorial(TutorialEntity tutorial) async {
    await repository.saveTutorial(tutorial);
  }
}
