import 'package:climbing_diary/interfaces/my_base_interface/my_base_interface.dart';
import 'package:climbing_diary/interfaces/trip/update_trip.dart';

import 'create_trip.dart';

class Trip extends MyBaseInterface{
  static const String boxName = 'trips';
  static const String deleteBoxName = 'delete_trips';

  final List<String> spotIds;

  final String comment;
  final String endDate;
  final String name;
  final int rating;
  final String startDate;

  const Trip({
    required super.updated,
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
      updated: json['updated'],
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
      updated: cache['updated'],
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      spotIds: cache['spot_ids'] != null ? List<String>.from(cache['spot_ids']) : [],
      id: cache['_id'],
      userId: cache['user_id'],
      comment: cache['comment'],
      endDate: cache['end_date'],
      name: cache['name'],
      rating: cache['rating'],
      startDate: cache['start_date'],
    );
  }

  @override
  Map toJson() => {
    "updated": updated,
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

  CreateTrip toCreateTrip() {
    return CreateTrip(
      comment: comment,
      endDate: endDate,
      name: name,
      rating: rating,
      startDate: startDate,
    );
  }

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

  @override
  int get hashCode {
    int mediaIdsHashCode = 0;
    for (String mediaId in mediaIds) {
      if (mediaIdsHashCode == 0) {
        mediaIdsHashCode = mediaId.hashCode;
      } else {
        mediaIdsHashCode = mediaIdsHashCode ^ mediaId.hashCode;
      }
    }
    int spotIdsHashCode = 0;
    for (String spotId in spotIds) {
      if (spotIdsHashCode == 0) {
        spotIdsHashCode = spotId.hashCode;
      } else {
        spotIdsHashCode = spotIdsHashCode ^ spotId.hashCode;
      }
    }
    return
      mediaIdsHashCode ^
      spotIdsHashCode ^
      comment.hashCode ^
      endDate.hashCode ^
      name.hashCode ^
      rating.hashCode ^
      startDate.hashCode;
  }

  @override
  bool operator ==(Object other){
    return hashCode == other.hashCode;
  }
}