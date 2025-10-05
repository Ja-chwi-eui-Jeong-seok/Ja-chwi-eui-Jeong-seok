class AddMissionEntity {
  final String? id;
  final int missionCode;
  final String missionTag;
  final String missionTitle;

  AddMissionEntity({
    this.id,
    required this.missionCode,
    required this.missionTag,
    required this.missionTitle
  });
}
