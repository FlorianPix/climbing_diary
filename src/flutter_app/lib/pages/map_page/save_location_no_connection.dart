import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../components/add/add_spot.dart';
import '../../interfaces/spot/spot.dart';
import '../../services/location_service.dart';


class SaveLocationNoConnectionPage extends StatefulWidget {
  const SaveLocationNoConnectionPage({super.key, required this.onAdd, required this.onNetworkChange});

  final ValueSetter<Spot> onAdd;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<SaveLocationNoConnectionPage> createState() => _SaveLocationNoConnectionPage();
}

class _SaveLocationNoConnectionPage extends State<SaveLocationNoConnectionPage> {
  final LocationService locationService = LocationService();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: locationService.getPosition(),
      builder: (context, AsyncSnapshot<Position> snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) {
          return Scaffold(body: Center(child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [Padding(
              padding: EdgeInsets.all(50),
              child: SizedBox(
                height: 100.0,
                width: 100.0,
                child: CircularProgressIndicator(),
              ),
            )
            ],
          )));
        }
        Position position = snapshot.data!;
        return Scaffold(body: AddSpot(
          onAdd: widget.onAdd,
          onNetworkChange: widget.onNetworkChange,
        ));
      }
    );
  }
}
