class Media {
  final String id;
  final String userId;
  final String title;
  final String createdAt;

  const Media({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      createdAt: json['created_at']
    );
  }
}