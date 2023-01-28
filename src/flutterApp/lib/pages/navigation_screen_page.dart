import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:permission_handler/permission_handler.dart';

import '../components/add_spot.dart';

class NavigationScreenPage extends StatefulWidget {
  const NavigationScreenPage({super.key});

  @override
  State<NavigationScreenPage> createState() => _NavigationScreenPage();
}

class _NavigationScreenPage extends State<NavigationScreenPage> {
  LatLng targetLocation = LatLng(50.746036, 10.642666);
  LatLong _center = LatLong(50.746036, 10.642666);
  String address = "";
  List values = [1, 2, 3, 4, 5];
  double currentSliderValue = 1;

  @override
  initState(){
    super.initState();
    getLocation();
  }

  getLocation() async {
    if (await Permission.location.serviceStatus.isEnabled) {
      var status = await Permission.location.status;
      if (status.isGranted) {
      } else if (status.isDenied) {
        Map<Permission, PermissionStatus> status = await [
          Permission.location,
        ].request();
      }
    } else {
      // permission is disabled
    }
    if (await Permission.location.isPermanentlyDenied) {
      openAppSettings();
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _center = LatLong(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OpenStreetMapSearchAndPick(
        center: _center,
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
        }
      )
    );
  }
}
