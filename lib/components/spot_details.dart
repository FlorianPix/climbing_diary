import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../interfaces/spot.dart';
import '../services/spot_service.dart';

class SpotDetails extends StatelessWidget {
  final Spot spot;

  const SpotDetails({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Name: ${spot.name}'),
            Text('Date: ${spot.date}'),
            Text('Coordinates: ${spot.coordinates}'),
            Text('Country: ${spot.country}'),
            Text('Location: ${spot.location}'),
            Text('Routes: ${spot.routes}'),
            Text('Rating: ${spot.rating}'),
            Text('Comments: ${spot.comments}'),
            Text('Family friendly: ${spot.familyFriendly}'),
            Text('Distance to parking: ${spot.distanceParking} min'),
            Text('Distance to public transport: ${spot.distancePublicTransport} min'),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        )),
      ),
    );
  }
}