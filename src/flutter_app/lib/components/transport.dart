import 'package:flutter/material.dart';

class Transport extends StatelessWidget{
  const Transport({super.key, required this.distancePublicTransport, required this.distanceParking});

  final int distancePublicTransport, distanceParking;

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
        padding: const EdgeInsets.all(5),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Icon(Icons.train, size: 30.0, color: Colors.green),
            Text(
              '$distancePublicTransport min',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400
              ),
            ),
            const Icon(Icons.directions_car, size: 30.0, color: Colors.red),
            Text(
              '$distanceParking min',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400
              ),
            )
          ],
        )
    ));
  }

}