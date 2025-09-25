import '../../domain/entities/tutorial_entity.dart';
import '../../domain/repositories/tutorial_repository.dart';
import '../datasources/tutorial_datasource.dart';
import '../models/tutorial_model.dart';

class TutorialRepositoryImpl implements TutorialRepository {
  final TutorialDataSource dataSource;

  TutorialRepositoryImpl(this.dataSource);

  @override
  Future<TutorialEntity?> getTutorial(String accountData) async {
    return await dataSource.fetchTutorial(accountData);
  }

  @override
  Future<void> saveTutorial(TutorialEntity tutorial) async {
    final model = TutorialModel(
      accountData: tutorial.accountData,
      tutorialCheckUp: tutorial.tutorialCheckUp,
      tutorialCreateDate: tutorial.tutorialCreateDate,
    );
    await dataSource.saveTutorial(model);
  }
}
