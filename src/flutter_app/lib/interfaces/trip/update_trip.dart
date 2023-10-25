import 'package:climbing_diary/interfaces/my_base_interface/update_my_base_interface.dart';
import 'package:climbing_diary/interfaces/trip/trip.dart';

class UpdateTrip extends UpdateMyBaseInterface{
  static const String boxName = 'edit_trips';

  List<String>? spotIds;
  String? comment;
  String? endDate;
  String? name;
  int? rating;
  String? startDate;

  UpdateTrip({
    super.mediaIds,
    this.spotIds,
    required super.id,
    super.userId,
    this.comment,
    this.endDate,
    this.name,
    this.rating,
    this.startDate,
  });

  factory UpdateTrip.fromJson(Map<String, dynamic> json) {
    return UpdateTrip(
      mediaIds: List<String>.from(json['media_ids']),
      spotIds: List<String>.from(json['spot_ids']),
      id: json['_id'],
      userId: json['user_id'],
      comment: json['comment'],
      endDate: json['end_date'],
      name: json['name'],
      rating: json['rating'],
      startDate: json['start_date'],
    );
  }

  factory UpdateTrip.fromCache(Map<dynamic, dynamic> cache) {
    return UpdateTrip(
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

  Trip toTrip(Trip oldTrip){
    return Trip(
      updated: DateTime.now().toIso8601String(),
      mediaIds: mediaIds != null ? mediaIds! : oldTrip.mediaIds,
      spotIds: spotIds != null ? spotIds! : oldTrip.spotIds,
      id: id,
      userId: userId != null ? userId! : oldTrip.userId,
      comment: comment != null ? comment! : oldTrip.comment,
      endDate: endDate != null ? endDate! : oldTrip.endDate,
      name: name != null ? name! : oldTrip.name,
      rating: rating != null ? rating! : oldTrip.rating,
      startDate: startDate != null ? startDate! : oldTrip.startDate,
    );
  }

  @override
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
}