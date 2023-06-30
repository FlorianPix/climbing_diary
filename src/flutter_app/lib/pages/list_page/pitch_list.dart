import 'package:climbing_diary/interfaces/multi_pitch_route/multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';
import 'package:flutter/material.dart';
import '../../../services/pitch_service.dart';
import '../../../services/route_service.dart';
import '../../interfaces/pitch/pitch.dart';
import 'pitch_details.dart';

class PitchList extends StatefulWidget {
  const PitchList({super.key, required this.pitches});

  final List<Pitch> pitches;

  @override
  State<StatefulWidget> createState() => PitchListState();
}

class PitchListState extends State<PitchList> {
  final RouteService routeService = RouteService();
  final PitchService pitchService = PitchService();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Pitch> pitches = widget.pitches;
    pitches.sort((a, b) => a.name.compareTo(b.name));
    return Column(
      children: pitches.map((pitch) => buildList(pitch)).toList(),
    );
  }

  Widget buildList(Pitch pitch){
    return ExpansionTile(
        title: Text(
          "${pitch.name} (${pitch.num})",
        ),
        children: [Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: PitchDetails(
              pitch: pitch,
            ))]
    );
  }
}