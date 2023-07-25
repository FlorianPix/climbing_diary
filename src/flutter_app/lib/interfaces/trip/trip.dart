import 'package:climbing_diary/interfaces/my_base_interface/my_base_interface.dart';
import 'package:climbing_diary/interfaces/trip/update_trip.dart';

class Trip extends MyBaseInterface{
  final List<String> spotIds;

  final String comment;
  final String endDate;
  final String name;
  final int rating;
  final String startDate;

  const Trip({
    required super.mediaIds,
    required this.spotIds,
    required super.id,
    required super.userId,
    required this.comment,
    required this.endDate,
    required this.name,
    required this.rating,
    required this.startDate,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      mediaIds: List<String>.from(json['media_ids']),
      spotIds: List<String>.from(json['spot_ids']),
      id: json['_id'],
      userId: json['user_id'],
      comment: json['comment'],
      endDate: json['end_date'],
      name: json['name'],
      rating: json['rating'],
      startDate: json['start_date']
    );
  }

  factory Trip.fromCache(Map<dynamic, dynamic> cache) {
    return Trip(
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      spotIds: cache['spots'] != null ? List<String>.from(cache['spots']) : [],
      id: cache['_id'],
      userId: cache['user_id'],
      comment: cache['comment'],
      endDate: cache['end_date'],
      name: cache['name'],
      rating: cache['rating'],
      startDate: cache['start_date'],
    );
  }

  Map toJson() => {
    "media_ids": mediaIds,
    "spot_ids": spotIds,
    "_id": id,
    "user_id": userId,
    "comment": comment,
    "end_date": endDate,
    "name": name,
    "rating": rating,
    "start_date": startDate,
  };

  UpdateTrip toUpdateTrip() {
    return UpdateTrip(
      mediaIds: mediaIds,
      spotIds: spotIds,
      id: id,
      userId: userId,
      comment: comment,
      endDate: endDate,
      name: name,
      rating: rating,
      startDate: startDate,
    );
  }
}