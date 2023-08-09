class CreateAscent {
  static const String boxName = 'create_ascents';

  final String? comment;
  final String date;
  final int style;
  final int type;
  
  const CreateAscent({
    this.comment,
    required this.date,
    required this.style,
    required this.type,
  });

  factory CreateAscent.fromJson(Map<String, dynamic> json) {
    return CreateAscent(
      comment: json['comment'],
      date: json['date'],
      style: json['style'],
      type: json['type'],
    );
  }

  factory CreateAscent.fromCache(Map<dynamic, dynamic> cache) {
    return CreateAscent(
      comment: cache['comment'],
      date: cache['date'],
      style: cache['style'],
      type: cache['type'],
    );
  }

  Map toJson() => {
    "comment": comment,
    "date": date,
    "style": style,
    "type": type,
  };

  @override
  int get hashCode {
    return
      comment.hashCode ^
      date.hashCode ^
      style.hashCode ^
      type.hashCode;
  }

  @override
  bool operator ==(Object other){
    return hashCode == other.hashCode;
  }
}