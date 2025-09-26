import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/data/datasources/tutorial_datasource.dart';
import 'package:ja_chwi/data/repositories/tutorial_repository_impl.dart';
import 'package:ja_chwi/domain/entities/tutorial_entity.dart';
import 'package:ja_chwi/domain/usecases/tutorial_usecase.dart';
import 'package:ja_chwi/presentation/providers/firestore_provider.dart';

final tutorialProvider =
    StateNotifierProvider<TutorialNotifier, TutorialEntity?>(
      (ref) => TutorialNotifier(ref.watch(tutorialUseCaseProvider)),
    );

final tutorialUseCaseProvider = Provider<TutorialUseCase>((ref) {
  final dataSource = TutorialDataSource(ref.read(firestoreProvider));
  final repository = TutorialRepositoryImpl(dataSource);
  return TutorialUseCase(repository);
});

class TutorialNotifier extends StateNotifier<TutorialEntity?> {
  final TutorialUseCase useCase;

  TutorialNotifier(this.useCase) : super(null);

  Future<void> loadTutorial(String accountData) async {
    state = await useCase.checkTutorialStatus(accountData);
  }

  Future<void> completeTutorial(String accountData) async {
    final tutorial = TutorialEntity(
      accountData: accountData,
      tutorialCheckUp: true,
      tutorialCreateDate: DateTime.now(),
    );
    await useCase.completeTutorial(tutorial);
    state = tutorial;
  }
}
