import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../components/add_spot.dart';
import 'package:latlong2/latlong.dart';

import '../services/location_service.dart';

class SaveLocationNoConnectionPage extends StatefulWidget {
  const SaveLocationNoConnectionPage({super.key});

  @override
  State<SaveLocationNoConnectionPage> createState() =>
      _SaveLocationNoConnectionPage();
}

class _SaveLocationNoConnectionPage extends State<SaveLocationNoConnectionPage> {
  final LocationService locationService = LocationService();

  @override
  initState() {
    super.initState();
  }

  @override
  //Just a test case for "Save spot" - feature
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: locationService.getPosition(),
      builder: (context, AsyncSnapshot<Position> snapshot) {
        if (snapshot.hasData) {
          Position position = snapshot.data!;
          return Scaffold(
            body: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: const Text(
                      'Save spot with current location',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AddSpot(
                          coordinates:
                          LatLng(position.latitude, position.longitude),
                          address: " "));
                    },
                  ),
                ]
              )
            )
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return Scaffold(
          body: Center (
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const <Widget>[
                Padding(
                  padding: EdgeInsets.all(50),
                  child: SizedBox(
                    height: 100.0,
                    width: 100.0,
                    child: CircularProgressIndicator(),
                  ),
                )
              ],
            )
          ));
        }
    );
  }
}
