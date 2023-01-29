import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../components/add_spot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';

class SaveLocationNoConnectionPage extends StatefulWidget {
  const SaveLocationNoConnectionPage({super.key});

  @override
  State<SaveLocationNoConnectionPage> createState() =>
      _SaveLocationNoConnectionPage();
}

class _SaveLocationNoConnectionPage extends State<SaveLocationNoConnectionPage> {

  @override
  initState() {
    super.initState();
  }

  @override
  //Just a test case for "Save spot" - feature
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: getPosition(),
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
                    height: 200.0,
                    width: 200.0,
                    child: CircularProgressIndicator(),
                  ),
                )
              ],
            )
          ));
        }
    );
  }

  Future<Position> getPosition() async {
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

    return await Geolocator.getCurrentPosition();
  }
}
