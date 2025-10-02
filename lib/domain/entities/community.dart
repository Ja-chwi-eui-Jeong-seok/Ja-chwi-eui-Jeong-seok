class Community {
  final String id; // = doc.id (communityCode)
  final int categoryCode;
  final int categoryDetailCode;
  final String communityName; // communityName
  final String communityDetail; // communityDetail
  final String createUser; // createUser
  final String location; // 동명
  final DateTime communityCreateDate;
  final DateTime? communityUpdateDate;
  final DateTime? communityDeleteDate;
  final bool communityDeleteYn;
  final String? communityDeleteNote;

  const Community({
    required this.id,
    required this.categoryCode,
    required this.categoryDetailCode,
    required this.communityName,
    required this.communityDetail,
    required this.createUser,
    required this.location,
    required this.communityCreateDate,
    this.communityUpdateDate,
    this.communityDeleteDate,
    required this.communityDeleteYn,
    this.communityDeleteNote,
  });

  Community copyWith({
    String? name,
    String? detail,
    String? location,
    bool? isDeleted,
    String? deleteNote,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Community(
      id: id,
      categoryCode: categoryCode,
      categoryDetailCode: categoryDetailCode,
      communityName: name ?? communityName,
      communityDetail: detail ?? communityDetail,
      createUser: createUser,
      location: location ?? this.location,
      communityCreateDate: communityCreateDate,
      communityUpdateDate: updatedAt ?? communityUpdateDate,
      communityDeleteDate: deletedAt ?? communityDeleteDate,
      communityDeleteYn: isDeleted ?? communityDeleteYn,
      communityDeleteNote: deleteNote ?? communityDeleteNote,
    );
  }
}
