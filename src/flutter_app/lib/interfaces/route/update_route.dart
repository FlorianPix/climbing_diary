import 'package:climbing_diary/interfaces/my_base_interface/update_my_base_interface.dart';

class UpdateClimbingRoute extends UpdateMyBaseInterface{
  String? comment;
  String? location;
  String? name;
  int? rating;

  UpdateClimbingRoute({
    super.mediaIds,
    required super.id,
    super.userId,
    this.comment,
    this.location,
    this.name,
    this.rating,
  });

  factory UpdateClimbingRoute.fromJson(Map<String, dynamic> json) {
    return UpdateClimbingRoute(
      mediaIds: List<String>.from(json['media_ids']),
      id: json['_id'],
      userId: json['user_id'],
      comment: json['comment'],
      location: json['location'],
      name: json['name'],
      rating: json['rating'],
    );
  }

  factory UpdateClimbingRoute.fromCache(Map<dynamic, dynamic> cache) {
    return UpdateClimbingRoute(
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      id: cache['_id'],
      userId: cache['user_id'],
      comment: cache['comment'],
      location: cache['location'],
      name: cache['name'],
      rating: cache['rating'],
    );
  }

  @override
  Map toJson() => {
    "media_ids": mediaIds,
    "_id": id,
    "user_id": userId,
    "comment": comment,
    "location": location,
    "name": name,
    "rating": rating,
  };
}