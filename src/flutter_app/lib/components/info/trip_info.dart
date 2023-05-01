import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../interfaces/trip/trip.dart';

class TripInfo extends StatelessWidget {
  const TripInfo({super.key,
    required this.trip
  });

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    List<Widget> listInfo = [];

    // name
    listInfo.add(Text(
      trip.name,
      style: const TextStyle(
          color: Color(0xff444444),
          fontSize: 18.0,
          fontWeight: FontWeight.w800
      ),
    ));

    listInfo.add(Text(
      "${trip.startDate} ${trip.endDate}",
      style: const TextStyle(
          color: Color(0xff989898),
          fontSize: 12.0,
          fontWeight: FontWeight.w400
      ),
    ));

    listInfo.add(Text(
      trip.comment,
      style: const TextStyle(
          color: Color(0xff989898),
          fontSize: 12.0,
          fontWeight: FontWeight.w400
      ),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listInfo,
    );
  }
}