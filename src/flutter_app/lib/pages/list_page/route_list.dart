import 'package:climbing_diary/interfaces/multi_pitch_route/multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';
import 'package:flutter/material.dart';
import '../../../services/pitch_service.dart';
import '../../../services/route_service.dart';
import 'multi_pitch_route_details.dart';
import 'single_pitch_route_details.dart';

class RouteList extends StatefulWidget {
  const RouteList({super.key, required this.singlePitchRoutes, required this.multiPitchRoutes, required this.onNetworkChange});

  final List<SinglePitchRoute> singlePitchRoutes;
  final List<MultiPitchRoute> multiPitchRoutes;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => RouteListState();
}

class RouteListState extends State<RouteList> {
  final RouteService routeService = RouteService();
  final PitchService pitchService = PitchService();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<SinglePitchRoute> singlePitchRoutes = widget.singlePitchRoutes;
    List<MultiPitchRoute> multiPitchRoutes = widget.multiPitchRoutes;

    singlePitchRoutes.sort((a, b) => a.name.compareTo(b.name));
    multiPitchRoutes.sort((a, b) => a.name.compareTo(b.name));

    List<Widget> elements = singlePitchRoutes.map((route) => buildSinglePitchRouteList(route)).toList();
    elements += multiPitchRoutes.map((route) => buildMultiPitchRouteList(route)).toList();

    return Column(children: elements);
  }

  Widget buildSinglePitchRouteList(SinglePitchRoute route){
    return ExpansionTile(
      title: Text(route.name),
      children: [Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SinglePitchRouteDetails(
          route: route,
          onNetworkChange: widget.onNetworkChange
        )
      )]
    );
  }

  Widget buildMultiPitchRouteList(MultiPitchRoute route){
    return ExpansionTile(
      title: Text(route.name),
      children: [Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: MultiPitchRouteDetails(
          route: route,
          onNetworkChange: widget.onNetworkChange,
        )
      )]
    );
  }
}