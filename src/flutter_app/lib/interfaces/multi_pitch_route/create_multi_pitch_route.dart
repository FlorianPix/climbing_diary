import 'package:climbing_diary/interfaces/route/create_route.dart';

class CreateMultiPitchRoute extends CreateClimbingRoute {
  static const String boxName = 'create_multi_pitch_routes';

  const CreateMultiPitchRoute({
    super.comment,
    required super.location,
    required super.name,
    required super.rating,
  });

  factory CreateMultiPitchRoute.fromJson(Map<String, dynamic> json) {
    return CreateMultiPitchRoute(
      comment: json['comment'],
      location: json['location'],
      name: json['name'],
      rating: json['rating'],
    );
  }

  factory CreateMultiPitchRoute.fromCache(Map<dynamic, dynamic> cache) {
    return CreateMultiPitchRoute(
      comment: cache['comment'],
      location: cache['location'],
      name: cache['name'],
      rating: cache['rating'],
    );
  }

  @override
  int get hashCode {
    return
      comment.hashCode ^
      location.hashCode ^
      name.hashCode ^
      rating.hashCode;
  }

  @override
  bool operator ==(Object other){
    return hashCode == other.hashCode;
  }
}