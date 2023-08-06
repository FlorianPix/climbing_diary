import 'spot_details.dart';
import 'package:flutter/material.dart';

import '../../../interfaces/spot/spot.dart';
import '../../../services/spot_service.dart';

class SpotList extends StatefulWidget {
  const SpotList({super.key, required this.spots, required this.onNetworkChange});

  final List<Spot> spots;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => SpotListState();
}

class SpotListState extends State<SpotList> {
  final SpotService spotService = SpotService();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Spot> spots = widget.spots;
    spots.sort((a, b) => a.name.compareTo(b.name));
    return Column(children: spots.map((spot) => buildList(spot)).toList());
  }

  Widget buildList(Spot spot){
    return ExpansionTile(
      title: Text(spot.name),
      children: [Padding(padding: const EdgeInsets.only(left: 20, right: 20), child: SpotDetails(
        spot: spot,
        onNetworkChange: widget.onNetworkChange,
      ))]
    );
  }
}