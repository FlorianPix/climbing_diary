class CreateTrip {
  final String? comment;
  final String endDate;
  final String name;
  final int rating;
  final String startDate;

  const CreateTrip({
    this.comment,
    required this.endDate,
    required this.name,
    required this.rating,
    required this.startDate,
  });

  factory CreateTrip.fromJson(Map<String, dynamic> json) {
    return CreateTrip(
      comment: json['comment'],
      endDate: json['end_date'],
      name: json['name'],
      rating: json['rating'],
      startDate: json['start_date'],
    );
  }

  factory CreateTrip.fromCache(Map<dynamic, dynamic> cache) {
    return CreateTrip(
      comment: cache['comment'],
      endDate: cache['end_date'],
      name: cache['name'],
      rating: cache['rating'],
      startDate: cache['start_date'],
    );
  }

  Map toJson() => {
    "comment": comment,
    "end_date": endDate,
    "name": name,
    "rating": rating,
    "start_date": startDate,
  };
}