import 'package:climbing_diary/components/detail/pitch_details.dart';
import 'package:climbing_diary/interfaces/grading_system.dart';
import 'package:flutter/material.dart';

import '../../interfaces/single_pitch_route/single_pitch_route.dart';
import '../../interfaces/spot/spot.dart';
import '../../interfaces/trip/trip.dart';
import '../MyTextStyles.dart';

class SinglePitchRouteInfo extends StatelessWidget {
  const SinglePitchRouteInfo({super.key, this.trip, required this.spot, required this.route});

  final Trip? trip;
  final Spot spot;
  final SinglePitchRoute route;

  @override
  Widget build(BuildContext context) {
    List<Widget> listInfo = [];

    listInfo.add(Text(
      "📖 ${route.grade.grade} ${route.grade.system.toShortString()} 📏 ${route.length}m",
      style: MyTextStyles.description,
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: listInfo,
    );
  }
}