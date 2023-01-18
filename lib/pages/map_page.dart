import 'dart:convert';

import 'package:climbing_diary/components/spot_details.dart';
import 'package:climbing_diary/pages/navigation_screen_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../interfaces/spot.dart';
import '../services/spot_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>{
  int _counter = 0;
  final SpotService spotService = SpotService();

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  late Future<List<Spot>> futureSpots;

  @override
  void initState(){
    super.initState();
    futureSpots = spotService.fetchSpots();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
          child: FutureBuilder<List<Spot>>(
              future: futureSpots,
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  var spots = snapshot.data!;
                  return FlutterMap(
                    options: MapOptions(
                      center: LatLng(spots[0].coordinates[0], spots[0].coordinates[1]),
                      zoom: 5,
                    ),
                    nonRotatedChildren: [
                      AttributionWidget.defaultWidget(
                        source: 'OpenStreetMap contributors',
                        onSourceTapped: null,
                      ),
                    ],
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                          markers: getMarkers(spots)
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              }
          )
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NavigationScreenPage()),
            );
          },
          child: const Icon(Icons.add)// Comes pick destination icon
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  getMarkers(List<Spot> spots){
    List<Marker> markers = [];
    for (var spot in spots) {
      markers.add(Marker(
        point: LatLng(spot.coordinates[0], spot.coordinates[1]),
        width: 80,
        height: 80,
        builder: (context) => IconButton(
          icon: const Icon(Icons.place, size: 30.0, color: Colors.pink),
          tooltip: spot.name,
          onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SpotDetails(spot: spot)
              ),
            ),
          ),
        ),
      );
    }
    return markers;
  }
}