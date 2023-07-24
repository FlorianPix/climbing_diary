import 'package:climbing_diary/interfaces/my_base_interface/update_my_base_interface.dart';

class MyBaseInterface {
  final List<String> mediaIds;
  final String id;
  final String userId;

  const MyBaseInterface({
    required this.mediaIds,
    required this.id,
    required this.userId
  });

  factory MyBaseInterface.fromJson(Map<String, dynamic> json) {
    return MyBaseInterface(
      mediaIds: List<String>.from(json['media_ids']),
      id: json['_id'],
      userId: json['user_id']
    );
  }

  factory MyBaseInterface.fromCache(Map<dynamic, dynamic> cache) {
    return MyBaseInterface(
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      id: cache['_id'],
      userId: cache['user_id']
    );
  }

  Map toJson() => {
    "media_ids": mediaIds,
    "_id": id,
    "user_id": userId
  };

  UpdateMyBaseInterface toUpdateMyBaseInterface() {
    return UpdateMyBaseInterface(
      mediaIds: mediaIds,
      id: id,
      userId: userId
    );
  }
}