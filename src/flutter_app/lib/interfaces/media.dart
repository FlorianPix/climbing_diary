import 'dart:typed_data';

class Media {
  static const String boxName = 'media';
  static const String deleteBoxName = 'delete_media';

  final String id;
  final String userId;
  final String title;
  final String createdAt;
  final Uint8List image;

  const Media({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.image,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      createdAt: json['created_at'],
      image: json['image']
    );
  }

  factory Media.fromCache(Map<dynamic, dynamic> cache) {
    return Media(
      createdAt: cache['createdAt'],
      id: cache['_id'],
      userId: cache['user_id'],
      title: cache['title'],
      image: cache['image']
    );
  }

  Map toJson() => {
    "createdAt": createdAt,
    "_id": id,
    "user_id": userId,
    "title": title,
    "image": image
  };
}