import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../interfaces/spot/spot.dart';
import '../my_text_styles.dart';

class SpotInfo extends StatelessWidget {
  const SpotInfo({super.key, required this.spot});

  final Spot spot;

  @override
  Widget build(BuildContext context) {
    List<Widget> listInfo = [];

    listInfo.add(Text(spot.name, style: MyTextStyles.title));
    listInfo.add(Text(
      '${round(spot.coordinates[0], decimals: 8)}, ${round(spot.coordinates[1], decimals: 8)}',
      style: MyTextStyles.description
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listInfo,
    );
  }
}