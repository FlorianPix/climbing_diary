import 'package:climbing_diary/interfaces/ascent/ascent.dart';

class DeleteAscent {
  static const String boxName = 'delete_ascents';

  final String pitchId;
  final Ascent ascent;
  final bool ofPitch;

  const DeleteAscent({
    required this.pitchId,
    required this.ascent,
    required this.ofPitch,
  });

  factory DeleteAscent.fromJson(Map<String, dynamic> json) {
    return DeleteAscent(
      pitchId: json['pitchId'],
      ascent: json['ascent'],
      ofPitch: json['ofPitch'],
    );
  }

  factory DeleteAscent.fromCache(Map<dynamic, dynamic> cache) {
    return DeleteAscent(
      pitchId: cache['pitchId'],
      ascent: Ascent.fromCache(cache['ascent']),
      ofPitch: cache['ofPitch'],
    );
  }

  Map toJson() => {
    "pitchId": pitchId,
    "ascent": ascent.toJson(),
    "ofPitch": ofPitch,
  };
}