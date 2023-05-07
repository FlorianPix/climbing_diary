import 'package:flutter/material.dart';

import '../../interfaces/pitch/pitch.dart';
import '../../interfaces/route/route.dart';
import '../../services/pitch_service.dart';
import '../../services/route_service.dart';

import '../MyButtonStyles.dart';

class SelectPitch extends StatefulWidget {
  const SelectPitch({super.key, required this.route});

  final ClimbingRoute route;
  @override
  State<StatefulWidget> createState() => _SelectPitchState();
}

class _SelectPitchState extends State<SelectPitch>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PitchService pitchService = PitchService();
  final RouteService routeService = RouteService();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text('Please choose a pitch'),
      content: FutureBuilder<List<Pitch>>(
        future: pitchService.getPitches(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Pitch> pitches = snapshot.data!;
            List<Widget> elements = <Widget>[];

            for (int i = 0; i < pitches.length; i++){
              elements.add(ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward, size: 30.0, color: Colors.pink),
                  label: Text(pitches[i].name),
                  onPressed: () {
                    if (!widget.route.pitchIds.contains(pitches[i].id)){
                      widget.route.pitchIds.add(pitches[i].id);
                      routeService.editRoute(widget.route.toUpdateClimbingRoute());
                    }
                    Navigator.of(context).pop();
                  },
                  style: MyButtonStyles.rounded
              ));
            }
            return Column(
              children: elements,
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}