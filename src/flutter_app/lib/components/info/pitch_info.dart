import 'package:climbing_diary/interfaces/grading_system.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../interfaces/pitch/pitch.dart';
import '../MyTextStyles.dart';

class PitchInfo extends StatelessWidget {
  const PitchInfo({super.key,
    required this.pitch
  });

  final Pitch pitch;

  @override
  Widget build(BuildContext context) {
    List<Widget> listInfo = [];

    // name
    listInfo.add(Text(
      pitch.name,
      style: MyTextStyles.title,
    ));

    listInfo.add(Text(
      "#️ ${pitch.num} 📖 ${pitch.grade.grade} ${pitch.grade.system.toShortString()} 📏 ${pitch.length}m",
      style: MyTextStyles.description,
    ));

    // comment
    listInfo.add(Text(
      pitch.comment,
      style: MyTextStyles.description,
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listInfo,
    );
  }
}