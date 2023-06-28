import 'package:climbing_diary/interfaces/route/create_route.dart';

class CreateMultiPitchRoute extends CreateClimbingRoute {

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
}