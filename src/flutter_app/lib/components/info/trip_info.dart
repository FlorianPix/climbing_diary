import 'package:flutter/material.dart';

import '../../interfaces/trip/trip.dart';
import 'package:climbing_diary/components/common/my_text_styles.dart';

class TripInfo extends StatelessWidget {
  const TripInfo({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    List<Widget> listInfo = [];

    listInfo.add(Text(trip.name, style: MyTextStyles.title));

    listInfo.add(Text(
      "${trip.startDate} ${trip.endDate}",
      style: MyTextStyles.description,
    ));

    if (trip.comment != ""){
      listInfo.add(Text(trip.comment, style: MyTextStyles.description));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listInfo,
    );
  }
}