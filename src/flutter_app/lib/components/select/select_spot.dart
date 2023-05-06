import 'package:climbing_diary/interfaces/trip/update_trip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../interfaces/spot/create_spot.dart';
import '../../interfaces/spot/spot.dart';
import '../../interfaces/trip/trip.dart';
import '../../services/spot_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../services/trip_service.dart';
import '../MyButtonStyles.dart';

class SelectSpot extends StatefulWidget {
  const SelectSpot({super.key, required this.trip});

  final Trip trip;
  @override
  State<StatefulWidget> createState() => _SelectSpotState();
}

class _SelectSpotState extends State<SelectSpot>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SpotService spotService = SpotService();
  final TripService tripService = TripService();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> elements = [];

    return AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text('Please choose a spot'),
      content: FutureBuilder<List<Spot>>(
        future: spotService.getSpots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Spot> spots = snapshot.data!;
            List<Widget> elements = <Widget>[];

            for (int i = 0; i < spots.length; i++){
              elements.add(ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward, size: 30.0, color: Colors.pink),
                  label: Text(spots[i].name),
                  onPressed: () {
                    if (!widget.trip.spotIds.contains(spots[i].id)){
                      widget.trip.spotIds.add(spots[i].id);
                      tripService.editTrip(widget.trip.toUpdateTrip());
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