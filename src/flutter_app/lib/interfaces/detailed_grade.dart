import 'ascent/ascent_style.dart';
import 'ascent/ascent_type.dart';
import 'grade.dart';

class DetailedGrade {
  final String date;
  final Grade grade;
  final AscentStyle ascentStyle;
  final AscentType ascentType;

  const DetailedGrade({
    required this.date,
    required this.grade,
    required this.ascentStyle,
    required this.ascentType,
  });
}