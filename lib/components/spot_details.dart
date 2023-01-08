import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../interfaces/spot.dart';

Widget spotDetails(context, Spot spot){
  String location = "";
  for (var i = 0; i < spot.location.length; i++){
    location += spot.location[i];
    location += ", ";
  }

  List<Widget> elements = [];

  elements.addAll([
    Text(
      spot.name,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600
      ),
    ),
    Text(
      spot.date,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400
      ),
    ),
    Text(
      '${round(spot.coordinates[0], decimals: 8)}, ${round(spot.coordinates[1], decimals: 8)}',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400
      ),
    ),
    Text(
      spot.country,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400
      ),
    ),
    Text(
      location,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400
      ),
    )]);

  List<Widget> ratingRowElements = [];

  for (var i = 0; i < 5; i++){
    if (spot.rating > i) {
      ratingRowElements.add(const Icon(Icons.favorite, size: 30.0, color: Colors.pink));
    } else {
      ratingRowElements.add(const Icon(Icons.favorite, size: 30.0, color: Colors.grey));
    }
  }

  elements.add(Center(child: Padding(
    padding: const EdgeInsets.all(10),
    child:Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ratingRowElements,
    )
  )));

  elements.add(Center(child: Padding(
      padding: const EdgeInsets.all(5),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const Icon(Icons.train, size: 30.0, color: Colors.green),
          Text(
            '${spot.distancePublicTransport} min',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400
            ),
          )
        ],
      )
  )));

  elements.add(Center(child: Padding(
      padding: const EdgeInsets.all(5),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const Icon(Icons.directions_car, size: 30.0, color: Colors.red),
          Text(
            '${spot.distanceParking} min',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400
            ),
          )
        ],
      )
  )));

  elements.add(
    Align(
      alignment: Alignment.bottomRight,
      child: TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Close'),
      ),
    )
  );

  return Stack(
      children: <Widget>[
        Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: elements
            )
        )
      ]
  );
}