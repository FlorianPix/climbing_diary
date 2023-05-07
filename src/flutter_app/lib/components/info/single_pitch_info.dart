import 'package:climbing_diary/interfaces/grading_system.dart';
import 'package:flutter/material.dart';

import '../../interfaces/pitch/pitch.dart';
import '../MyTextStyles.dart';

class SinglePitchInfo extends StatelessWidget {
  const SinglePitchInfo({super.key,
    required this.pitch
  });

  final Pitch pitch;

  @override
  Widget build(BuildContext context) {
    List<Widget> listInfo = [];

    // info
    listInfo.add(Text(
      "📖 ${pitch.grade.grade} ${pitch.grade.system.toShortString()} 📏 ${pitch.length}m",
      style: MyTextStyles.description,
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listInfo,
    );
  }
}