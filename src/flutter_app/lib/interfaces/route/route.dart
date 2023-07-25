import 'package:climbing_diary/interfaces/my_base_interface/my_base_interface.dart';
import 'package:climbing_diary/interfaces/route/update_route.dart';

class ClimbingRoute extends MyBaseInterface{

  final String comment;
  final String location;
  final String name;
  final int rating;

  const ClimbingRoute({
    required super.mediaIds,
    required super.id,
    required super.userId,
    required this.comment,
    required this.location,
    required this.name,
    required this.rating,
  });

  factory ClimbingRoute.fromJson(Map<String, dynamic> json) {
    return ClimbingRoute(
      mediaIds: List<String>.from(json['media_ids']),
      id: json['_id'],
      userId: json['user_id'],
      comment: json['comment'],
      location: json['location'],
      name: json['name'],
      rating: json['rating'],
    );
  }

  factory ClimbingRoute.fromCache(Map<dynamic, dynamic> cache) {
    return ClimbingRoute(
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      id: cache['_id'],
      userId: cache['user_id'],
      comment: cache['comment'],
      location: cache['location'],
      name: cache['name'],
      rating: cache['rating'],
    );
  }

  Map toJson() => {
    "media_ids": mediaIds,
    "_id": id,
    "user_id": userId,
    "comment": comment,
    "location": location,
    "name": name,
    "rating": rating,
  };

  UpdateClimbingRoute toUpdateClimbingRoute() {
    return UpdateClimbingRoute(
      mediaIds: mediaIds,
      id: id,
      userId: userId,
      comment: comment,
      location: location,
      name: name,
      rating: rating,
    );
  }
}