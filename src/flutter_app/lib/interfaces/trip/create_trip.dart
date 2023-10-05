import 'package:climbing_diary/interfaces/trip/trip.dart';
import 'package:uuid/uuid.dart';

class CreateTrip {
  static const String boxName = 'create_trips';

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

  Trip toTrip(){
    return Trip(
      updated: DateTime.now().toIso8601String(),
      mediaIds: [],
      spotIds: [],
      id: const Uuid().v4(),
      userId: '',
      comment: comment != null ? comment! : '',
      endDate: endDate,
      name: name,
      rating: rating,
      startDate: startDate
    );
  }

  @override
  int get hashCode {
    return
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