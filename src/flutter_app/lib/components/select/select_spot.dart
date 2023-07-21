import 'package:flutter/material.dart';

import '../../interfaces/spot/spot.dart';
import '../../interfaces/trip/trip.dart';
import '../../services/spot_service.dart';

import '../../services/trip_service.dart';
import '../my_button_styles.dart';

class SelectSpot extends StatefulWidget {
  const SelectSpot({super.key, required this.trip, required this.onAdd});

  final Trip trip;
  final ValueSetter<Spot> onAdd;

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
                  onPressed: () async {
                    if (!widget.trip.spotIds.contains(spots[i].id)){
                      widget.trip.spotIds.add(spots[i].id);
                      Trip? updatedTrip = await tripService.editTrip(widget.trip.toUpdateTrip());
                      widget.onAdd.call(spots[i]);
                    }
                    Navigator.popUntil(context, ModalRoute.withName('/'));
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