import 'package:flutter/material.dart';

import '../../interfaces/route/route.dart';
import '../../interfaces/spot/spot.dart';
import '../../services/route_service.dart';
import '../../services/spot_service.dart';

import '../MyButtonStyles.dart';

class SelectRoute extends StatefulWidget {
  const SelectRoute({super.key, required this.spot});

  final Spot spot;
  @override
  State<StatefulWidget> createState() => _SelectRouteState();
}

class _SelectRouteState extends State<SelectRoute>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RouteService routeService = RouteService();
  final SpotService tripService = SpotService();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text('Please choose a route'),
      content: FutureBuilder<List<ClimbingRoute>>(
        future: routeService.getRoutes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ClimbingRoute> routes = snapshot.data!;
            List<Widget> elements = <Widget>[];

            for (int i = 0; i < routes.length; i++){
              elements.add(ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward, size: 30.0, color: Colors.pink),
                  label: Text(routes[i].name),
                  onPressed: () {
                    if (!widget.spot.multiPitchRouteIds.contains(routes[i].id)){
                      widget.spot.multiPitchRouteIds.add(routes[i].id);
                      tripService.editSpot(widget.spot.toUpdateSpot());
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