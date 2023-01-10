import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../interfaces/spot.dart';

Widget spotDetails(context, Spot spot){
  String location = "";
  for (var i = 0; i < spot.location.length; i++){
    location += spot.location[i];
    if (i < spot.location.length - 1) {
      location += ", ";
    }
  }

  List<Widget> elements = [];

  // general info
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

  // rating
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

  if (spot.comments.isNotEmpty) {
    elements.add(Container(
        margin: const EdgeInsets.all(15.0),
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          spot.comments[0],
        )
    ));
  }

  // time to walk from public transport
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

  // time to walk from closest parking
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

  // close button
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