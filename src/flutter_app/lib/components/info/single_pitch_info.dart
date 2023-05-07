import 'package:climbing_diary/components/detail/pitch_details.dart';
import 'package:climbing_diary/interfaces/grading_system.dart';
import 'package:flutter/material.dart';

import '../../interfaces/pitch/pitch.dart';
import '../../interfaces/route/route.dart';
import '../../interfaces/spot/spot.dart';
import '../../interfaces/trip/trip.dart';
import '../MyButtonStyles.dart';
import '../MyTextStyles.dart';

class SinglePitchInfo extends StatelessWidget {
  const SinglePitchInfo({super.key, this.trip, required this.spot, required this.route, required this.pitch});

  final Trip? trip;
  final Spot spot;
  final ClimbingRoute route;
  final Pitch pitch;

  @override
  Widget build(BuildContext context) {
    List<Widget> listInfo = [];

    listInfo.add(Text(
      "📖 ${pitch.grade.grade} ${pitch.grade.system.toShortString()} 📏 ${pitch.length}m",
      style: MyTextStyles.description,
    ));

    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (BuildContext context) =>
            Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PitchDetails(
                    trip: trip,
                    spot: spot,
                    route: route,
                    pitch: pitch,
                    onDelete: (pitch) {
                      route.pitchIds.remove(pitch.id);
                    },
                    onUpdate: (pitch) {  },
                )
            ),
      ),
      child: Ink(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: listInfo,
          ),
      ),
    );
  }
}