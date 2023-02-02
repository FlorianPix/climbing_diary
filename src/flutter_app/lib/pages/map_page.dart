import 'package:climbing_diary/pages/save_location_no_connection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../components/spot_details.dart';
import 'navigation_screen_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../interfaces/spot.dart';
import '../services/spot_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final SpotService spotService = SpotService();

  late Future<List<Spot>> futureSpots;
  bool online = false;

  Future<bool> checkConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkConnection(),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          var online = snapshot.data!;
          if (online) {
            //if chache is'nt empty => upload
            Box box = Hive.box('saveSpot');
            var data = box.get('spot');
            if (data != null) {
              SpotService spot = SpotService();
              spot.uploadSpot(data);
              box.delete('spot');
            }
            futureSpots = spotService.getSpots();
            return FutureBuilder<List<Spot>>(
              future: futureSpots,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var spots = snapshot.data!;

                  addSpotCallback(Spot spot) {
                    spots.add(spot);
                    setState(() {});
                  }

                  updateCallback(Spot spot) {
                    var index = -1;
                    for (int i = 0; i < spots.length; i++) {
                      if (spots[i].id == spot.id) {
                        index = i;
                      }
                    }
                    spots.removeAt(index);
                    spots.add(spot);
                    setState(() {});
                  }

                  deleteSpotCallback(Spot spot) {
                    spots.remove(spot);
                    setState(() {});
                  }

                  if (spots.isEmpty) {
                    return Scaffold(
                      body: Center(
                        child: FlutterMap(
                          options: MapOptions(
                            center: LatLng(50.746036, 10.642666),
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
                              urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                          ],
                        )
                      ),
                      floatingActionButton: FloatingActionButton(
                        onPressed: () async {
                          if (online) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NavigationScreenPage(onAdd: addSpotCallback)),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (
                                  context) => SaveLocationNoConnectionPage(onAdd: addSpotCallback)),
                            );
                          }
                        },
                          child: const Icon(Icons.add)
                      ), // This trailing comma makes auto-formatting nicer for build methods.
                    );
                  }
                  return Scaffold(
                    body: Center(
                      child: FlutterMap(
                        options: MapOptions(
                          center: LatLng(spots[0].coordinates[0],
                              spots[0].coordinates[1]),
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
                            urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(
                              markers: getMarkers(spots, deleteSpotCallback, updateCallback)),
                        ],
                      )
                    ),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () async {
                        if (online) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (
                                context) => NavigationScreenPage(onAdd: addSpotCallback)),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (
                                context) => SaveLocationNoConnectionPage(onAdd: addSpotCallback)),
                          );
                        }
                      },
                      child: const Icon(Icons.add)
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else {
                  return const CircularProgressIndicator();
                }
              }
            );
          } else {
            return Scaffold(
              body: const Center(
                child: Text('No connection'),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  if (online) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigationScreenPage(onAdd: (Spot value) {})),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SaveLocationNoConnectionPage(onAdd: (Spot value) {})),
                    );
                  }
                },
                child: const Icon(Icons.add),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      });
  }

  getMarkers(List<Spot> spots, ValueSetter<Spot> deleteCallback, ValueSetter<Spot> updateCallback) {
    List<Marker> markers = [];
    for (var spot in spots) {
      markers.add(
        Marker(
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
                child: SpotDetails(spot: spot, onDelete: deleteCallback, onUpdate: updateCallback)),
            ),
          ),
        ),
      );
    }
    return markers;
  }
}
