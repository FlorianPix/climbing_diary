import '../grade.dart';

class CreatePitch {
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

  Map toJson() => {
    "comment": comment,
    "grade": grade,
    "length": length,
    "name": name,
    "num": num,
    "rating": rating,
  };
}