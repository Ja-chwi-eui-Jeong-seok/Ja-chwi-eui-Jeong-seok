enum BookmarkType { community, mission }

class BookmarkEntity {
  final String id; // 글 ID 혹은 미션 ID
  final BookmarkType type;
  final DateTime createdAt;

  BookmarkEntity({
    required this.id,
    required this.type,
    required this.createdAt,
  });
}
