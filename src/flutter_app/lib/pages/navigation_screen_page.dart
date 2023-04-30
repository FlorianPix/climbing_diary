import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

import '../components/add/add_spot.dart';
import '../interfaces/spot.dart';
import '../services/location_service.dart';

class NavigationScreenPage extends StatefulWidget {
  const NavigationScreenPage({super.key, required this.onAdd});

  final ValueSetter<Spot> onAdd;

  @override
  State<NavigationScreenPage> createState() => _NavigationScreenPage();
}

class _NavigationScreenPage extends State<NavigationScreenPage> {
  final LocationService locationService = LocationService();
  String address = "";
  List values = [1, 2, 3, 4, 5];
  double currentSliderValue = 1;

  @override
  initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: locationService.getPosition(),
      builder: (context, AsyncSnapshot<Position> snapshot) {
        if (snapshot.hasData) {
          Position position = snapshot.data!;
          return Scaffold(
            body: OpenStreetMapSearchAndPick(
              center: LatLong(position.latitude, position.longitude),
              buttonColor: Theme.of(context).colorScheme.primary,
              buttonText: 'Set location',
              onPicked: (pickedData) {
                setState(() {
                  address = pickedData.address;
                });
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                    AddSpot(
                      coordinates: LatLng(
                        pickedData.latLong.latitude,
                        pickedData.latLong.longitude
                      ),
                      address: address,
                      onAdd: widget.onAdd,
                    )
                );
              }
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
          )
        );
      }
    );
  }
}
