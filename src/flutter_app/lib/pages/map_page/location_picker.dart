import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

import '../../services/location_service.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key, required this.onAdd});

  final ValueSetter<List<String>> onAdd;

  @override
  State<LocationPicker> createState() => _NavigationScreenPage();
}

class _NavigationScreenPage extends State<LocationPicker> {
  final LocationService locationService = LocationService();
  String address = "";

  @override
  initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
        future: locationService.getPosition(),
        builder: (context, snapshot) {
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
                        widget.onAdd.call([address.toString(), pickedData.latLong.latitude.toString(), pickedData.latLong.longitude.toString()]);
                        Navigator.pop(context);
                      });
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
