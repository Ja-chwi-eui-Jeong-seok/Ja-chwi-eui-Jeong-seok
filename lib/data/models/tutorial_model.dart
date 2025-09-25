import 'package:ja_chwi/domain/entities/tutorial_entity.dart';

class TutorialModel extends TutorialEntity {
  TutorialModel({
    required String accountData,
    required bool tutorialCheckUp,
    required DateTime tutorialCreateDate,
  }) : super(
         accountData: accountData,
         tutorialCheckUp: tutorialCheckUp,
         tutorialCreateDate: tutorialCreateDate,
       );

  factory TutorialModel.fromJson(Map<String, dynamic> json) {
    return TutorialModel(
      accountData: json['account_data'] as String,
      tutorialCheckUp: json['tutorial_checkUp'] as bool,
      tutorialCreateDate: DateTime.parse(
        json['tutorial_create_date'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_data': accountData,
      'tutorial_checkUp': tutorialCheckUp,
      'tutorial_create_date': tutorialCreateDate.toIso8601String(),
    };
  }
}
