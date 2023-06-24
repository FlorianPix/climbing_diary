class UpdateSinglePitchRoute {
  List<String>? mediaIds;
  List<String>? pitchIds;
  final String id;
  String? userId;
  String? comment;
  String? location;
  String? name;
  int? rating;
  String? grade;
  int? length;

  UpdateSinglePitchRoute({
    this.mediaIds,
    this.pitchIds,
    required this.id,
    this.userId,
    this.comment,
    this.location,
    this.name,
    this.rating,
    this.grade,
    this.length
  });

  factory UpdateSinglePitchRoute.fromJson(Map<String, dynamic> json) {
    return UpdateSinglePitchRoute(
      mediaIds: List<String>.from(json['media_ids']),
      pitchIds: List<String>.from(json['pitch_ids']),
      id: json['_id'],
      userId: json['user_id'],
      comment: json['comment'],
      location: json['location'],
      name: json['name'],
      rating: json['rating'],
      grade: json['grade'],
      length: json['length'],
    );
  }

  factory UpdateSinglePitchRoute.fromCache(Map<dynamic, dynamic> cache) {
    return UpdateSinglePitchRoute(
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      pitchIds: cache['pitch_ids'] != null ? List<String>.from(cache['pitch_ids']) : [],
      id: cache['_id'],
      userId: cache['user_id'],
      comment: cache['comment'],
      location: cache['location'],
      name: cache['name'],
      rating: cache['rating'],
      grade: cache['rating'],
      length: cache['rating'],
    );
  }

  Map toJson() => {
    "media_ids": mediaIds,
    "pitch_ids": pitchIds,
    "_id": id,
    "user_id": userId,
    "comment": comment,
    "location": location,
    "name": name,
    "rating": rating,
    "grade": grade,
    "length": length,
  };
}