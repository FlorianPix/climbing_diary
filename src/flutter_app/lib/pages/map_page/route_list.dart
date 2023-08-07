import 'package:climbing_diary/pages/map_page/multi_pitch_route_list.dart';
import 'package:climbing_diary/pages/map_page/single_pitch_route_list.dart';
import 'package:flutter/material.dart';

import '../../../interfaces/spot/spot.dart';
import '../../../interfaces/trip/trip.dart';

class RouteList extends StatefulWidget {
  const RouteList({super.key, this.trip, required this.spot, required this.singlePitchRouteIds, required this.multiPitchRouteIds, required this.onNetworkChange});

  final Trip? trip;
  final Spot spot;
  final List<String> singlePitchRouteIds, multiPitchRouteIds;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => RouteListState();
}

class RouteListState extends State<RouteList> {
  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      MultiPitchRouteList(
          spot: widget.spot,
          multiPitchRouteIds: widget.multiPitchRouteIds,
          onNetworkChange: widget.onNetworkChange
      ),
      SinglePitchRouteList(
          spot: widget.spot,
          singlePitchRouteIds: widget.singlePitchRouteIds,
          onNetworkChange: widget.onNetworkChange
      )
    ]);
  }
}