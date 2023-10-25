import 'package:climbing_diary/interfaces/pitch/pitch.dart';
import 'package:uuid/uuid.dart';

import '../grade.dart';

class CreatePitch {
  static const String boxName = 'create_pitches';

  final String? comment;
  final Grade grade;
  final int length;
  final String name;
  final int num;
  final int rating;

  const CreatePitch({
    this.comment,
    required this.grade,
    required this.length,
    required this.name,
    required this.num,
    required this.rating,
  });

  factory CreatePitch.fromJson(Map<String, dynamic> json) {
    return CreatePitch(
      comment: json['comment'],
      grade: json['grade'],
      length: json['length'],
      name: json['name'],
      num: json['num'],
      rating: json['rating'],
    );
  }

  factory CreatePitch.fromCache(Map<dynamic, dynamic> cache) {
    return CreatePitch(
      comment: cache['comment'],
      grade: cache['grade'],
      length: cache['length'],
      name: cache['name'],
      num: cache['num'],
      rating: cache['rating'],
    );
  }

  Pitch toPitch(){
    return Pitch(
      updated: DateTime.now().toIso8601String(),
      mediaIds: [],
      id: const Uuid().v4(),
      userId: '',
      comment: comment != null ? comment! : '',
      name: name,
      rating: rating,
      ascentIds: [],
      grade: grade,
      length: length,
      num: num,
    );
  }

  Map toJson() => {
    "comment": comment,
    "grade": grade.toJson(),
    "length": length,
    "name": name,
    "num": num,
    "rating": rating,
  };

  @override
  int get hashCode {
    return
      comment.hashCode ^
      grade.hashCode ^
      length.hashCode ^
      name.hashCode ^
      num.hashCode ^
      rating.hashCode;
  }

  @override
  bool operator ==(Object other){
    return hashCode == other.hashCode;
  }
}