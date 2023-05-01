import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

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
      "📖 ${pitch.grade} 📏 ${pitch.length}m",
      style: MyTextStyles.description,
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listInfo,
    );
  }
}