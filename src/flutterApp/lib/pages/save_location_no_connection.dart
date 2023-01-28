import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import '../components/add_spot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class SaveLocationNoConnectionPage extends StatefulWidget {
  const SaveLocationNoConnectionPage({super.key});

  @override
  State<SaveLocationNoConnectionPage> createState() => _SaveLocationNoConnectionPage();
}
class _SaveLocationNoConnectionPage extends State<SaveLocationNoConnectionPage> {
  LatLong _center = LatLong(50.746036, 10.642666);

  @override
  initState(){
    super.initState();
    getLocation();
  }

  @override
  //Just a test case for "Save spot" - feature
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      padding: const EdgeInsets.all(32),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
            child: const Text('Save spot with current location',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400
              ),
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AddSpot(coordinates: LatLng(_center.latitude, _center.longitude), address: " ")
              );
            },
          ),
          ]
      )

    )
  );

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
      print("here is location ${_center}");
    });
  }

}