import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';
import 'package:flutter/material.dart';

import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/pitch/pitch.dart';
import '../../services/ascent_service.dart';
import '../../services/pitch_service.dart';
import '../../services/route_service.dart';
import '../MyButtonStyles.dart';

class SelectAscentOfSinglePitchRoute extends StatefulWidget {
  const SelectAscentOfSinglePitchRoute({super.key, required this.singlePitchRoute});

  final SinglePitchRoute singlePitchRoute;

  @override
  State<StatefulWidget> createState() => _SelectAscentOfSinglePitchRouteState();
}

class _SelectAscentOfSinglePitchRouteState extends State<SelectAscentOfSinglePitchRoute>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AscentService ascentService = AscentService();
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
      title: const Text('Please choose a ascent'),
      content: FutureBuilder<List<Ascent>>(
        future: ascentService.getAscents(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Ascent> ascents = snapshot.data!;
            List<Widget> elements = <Widget>[];

            for (int i = 0; i < ascents.length; i++){
              elements.add(ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward, size: 30.0, color: Colors.pink),
                  label: Text(ascents[i].date),
                  onPressed: () {
                    if (!widget.singlePitchRoute.ascentIds.contains(ascents[i].id)){
                      widget.singlePitchRoute.ascentIds.add(ascents[i].id);
                      routeService.editSinglePitchRoute(widget.singlePitchRoute.toUpdateSinglePitchRoute());
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