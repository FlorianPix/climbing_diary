import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

import '../components/add/add_spot.dart';
import '../interfaces/spot/spot.dart';
import '../interfaces/trip/trip.dart';
import '../services/location_service.dart';
import '../services/trip_service.dart';

class NavigationScreenPage extends StatefulWidget {
  const NavigationScreenPage({super.key, required this.onAdd});

  final ValueSetter<Spot> onAdd;

  @override
  State<NavigationScreenPage> createState() => _NavigationScreenPage();
}

class _NavigationScreenPage extends State<NavigationScreenPage> {
  final TripService tripService = TripService();
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
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([locationService.getPosition(), tripService.getTrips()]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Position position = snapshot.data![0];
          List<Trip> trips = snapshot.data![1];
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
                      trips: trips,
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
