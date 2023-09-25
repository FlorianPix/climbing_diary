import 'package:climbing_diary/interfaces/my_base_interface/update_my_base_interface.dart';

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