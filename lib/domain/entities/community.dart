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
      communityName: name ?? this.communityName,
      communityDetail: detail ?? this.communityDetail,
      createUser: createUser,
      location: location ?? this.location,
      communityCreateDate: communityCreateDate,
      communityUpdateDate: updatedAt ?? this.communityUpdateDate,
      communityDeleteDate: deletedAt ?? this.communityDeleteDate,
      communityDeleteYn: isDeleted ?? this.communityDeleteYn,
      communityDeleteNote: deleteNote ?? this.communityDeleteNote,
    );
  }
}
