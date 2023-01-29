import 'package:climbing_diary/pages/save_location_no_connection.dart';

import '../components/spot_details.dart';
import 'navigation_screen_page.dart';
import 'package:flutter/material.dart';
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

class _MapPageState extends State<MapPage>{
  final SpotService spotService = SpotService();

  late Future<List<Spot>> futureSpots;
  bool online = false;

  Future<bool> checkConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  @override
  void initState(){
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
            futureSpots = spotService.getSpots();
            return Scaffold(
              body: Center(
                  child: FutureBuilder<List<Spot>>(
                      future: futureSpots,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var spots = snapshot.data!;
                          deleteCallback(spot) {
                            spots.remove(spot);
                            setState(() {});
                          }

                          if (spots.isEmpty) {
                            return FlutterMap(
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
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.app',
                                ),
                              ],
                            );
                          }
                          return FlutterMap(
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
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app',
                              ),
                              MarkerLayer(
                                  markers: getMarkers(spots, deleteCallback)
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
                  onPressed: () async {
                    if (online) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NavigationScreenPage()),
                      );
                    }
                    else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (
                            context) => const SaveLocationNoConnectionPage()),
                      );
                    }
                  },
                  child: const Icon(Icons.add)
              ), // This trailing comma makes auto-formatting nicer for build methods.
            );
          } else {
            return const Scaffold(
                body: Center(child: Text('No connection'),)
            );
          }
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      }
    );
  }

  getMarkers(List<Spot> spots, ValueSetter<Spot> deleteCallback){
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
              child: SpotDetails(spot: spot, onDelete: deleteCallback)
              ),
            ),
          ),
        ),
      );
    }
    return markers;
  }

}