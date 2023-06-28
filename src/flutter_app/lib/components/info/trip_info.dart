import 'package:flutter/material.dart';

import '../../interfaces/trip/trip.dart';
import '../MyTextStyles.dart';

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
      style: MyTextStyles.title,
    ));

    listInfo.add(Text(
      "${trip.startDate} ${trip.endDate}",
      style: MyTextStyles.description,
    ));

    listInfo.add(Text(
      trip.comment,
      style: MyTextStyles.description,
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listInfo,
    );
  }
}