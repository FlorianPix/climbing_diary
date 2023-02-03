import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../interfaces/spot.dart';

class SpotInfo extends StatelessWidget {
  const SpotInfo({super.key,
    required this.spot
  });

  final Spot spot;

  @override
  Widget build(BuildContext context) {
    List<Widget> listInfo = [];

    // name
    listInfo.add(Text(
      spot.name,
      style: const TextStyle(
          color: Color(0xff9b9b9b),
          fontSize: 18.0,
          fontWeight: FontWeight.w800
      ),
    ));

    // date
    listInfo.add(Text(
      spot.date,
      style: const TextStyle(
        color: Color(0xff9b9b9b),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ));

    // coordinates
    listInfo.add(Text(
      '${round(spot.coordinates[0], decimals: 8)}, ${round(spot.coordinates[1], decimals: 8)}',
      style: const TextStyle(
        color: Color(0xff9b9b9b),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ));

    // location
    String location = "";
    for (var i = 0; i < spot.location.length; i++){
      location += spot.location[i];
      if (i < spot.location.length - 1) {
        location += ", ";
      }
    }
    listInfo.add(Text(
      location,
      style: const TextStyle(
        color: Color(0xff9b9b9b),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listInfo,
    );
  }
}