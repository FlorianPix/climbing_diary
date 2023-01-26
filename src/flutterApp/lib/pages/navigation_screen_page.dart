import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

import '../components/add_spot.dart';

class NavigationScreenPage extends StatefulWidget {
  const NavigationScreenPage({super.key});

  @override
  State<NavigationScreenPage> createState() => _NavigationScreenPage();
}

class _NavigationScreenPage extends State<NavigationScreenPage> {
  LatLng targetLocation = LatLng(50.746036, 10.642666);
  String address = "";
  List values = [1, 2, 3, 4, 5];
  double currentSliderValue = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: OpenStreetMapSearchAndPick(
      center: LatLong(50.746036, 10.642666),
      buttonColor: Colors.orange,
      buttonText: 'Set location',
      onPicked: (pickedData) {
        double lat = pickedData.latLong.latitude;
        double long = pickedData.latLong.longitude;
        setState(() {
          targetLocation = LatLng(lat, long);
          address = pickedData.address;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) => AddSpot(coordinates: targetLocation, address: address)
        );
      },
    ));
  }
}
