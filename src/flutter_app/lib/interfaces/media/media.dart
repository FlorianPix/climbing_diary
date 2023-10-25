import 'dart:typed_data';

class Media {
  static const String boxName = 'media';
  static const String createBoxName = 'create_media';
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
      id: json['_id'],
      userId: json['user_id'],
      title: json['title'],
      createdAt: json['created_at'],
      image: Uint8List.fromList(json['image'].cast<int>())
    );
  }

  factory Media.fromCache(Map<dynamic, dynamic> cache) {
    return Media(
      createdAt: cache['created_at'],
      id: cache['_id'],
      userId: cache['user_id'],
      title: cache['title'],
      image: Uint8List.fromList(cache['image'])
    );
  }

  Map toJson() => {
    "created_at": createdAt,
    "_id": id,
    "user_id": userId,
    "title": title,
    "image": image
  };

  @override
  int get hashCode {
    int imageHashCode = 0;
    for (var pixel in image) {
      if (imageHashCode == 0) {
        imageHashCode = pixel.hashCode;
      } else {
        imageHashCode = imageHashCode ^ pixel.hashCode;
      }
    }
    return
      createdAt.hashCode ^
      title.hashCode ^
      imageHashCode;
  }

  @override
  bool operator ==(Object other){
    return hashCode == other.hashCode;
  }
}