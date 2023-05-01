import 'package:climbing_diary/interfaces/route/route.dart';
import 'package:climbing_diary/pages/save_location_no_connection.dart';
import 'package:flutter/material.dart';

import '../components/add/add_ascent.dart';
import '../components/add/add_pitch.dart';
import '../components/add/add_route.dart';
import '../components/add/add_trip.dart';
import '../components/spot_details.dart';
import '../interfaces/pitch/pitch.dart';
import '../services/ascent_service.dart';
import '../services/cache.dart';
import '../services/pitch_service.dart';
import '../services/route_service.dart';
import '../services/trip_service.dart';
import 'navigation_screen_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../interfaces/spot/spot.dart';
import '../services/spot_service.dart';

enum AddItem { addTrip, addSpot, addRoute, addPitch, addAscent }

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final AscentService ascentService = AscentService();
  final PitchService pitchService = PitchService();
  final RouteService routeService = RouteService();
  final SpotService spotService = SpotService();
  final TripService tripService = TripService();
  AddItem? selectedMenu;

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
            deleteQueuedSpots();
            editQueuedSpots();
            uploadQueuedSpots();
            return FutureBuilder(
              future: Future.wait([
                spotService.getSpots(),
                routeService.getRoutes(),
                pitchService.getPitches()
              ]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Spot> spots = snapshot.data![0] as List<Spot>;
                  List<ClimbingRoute> routes = snapshot.data![1] as List<ClimbingRoute>;
                  List<Pitch> pitches = snapshot.data![2] as List<Pitch>;

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
                      floatingActionButton: PopupMenuButton<AddItem>(
                        initialValue: selectedMenu,
                        onSelected: (AddItem item) {
                          setState(() {
                            selectedMenu = item;
                          });
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<AddItem>>[
                          PopupMenuItem<AddItem>(
                            value: AddItem.addAscent,
                            child: IconButton(
                              icon: const Icon(Icons.adjust, size: 30.0),
                              onPressed: () {
                                print("asd");
                              },
                            )
                          ),
                          PopupMenuItem<AddItem>(
                              value: AddItem.addPitch,
                              child: IconButton(
                                icon: const Icon(Icons.start, size: 30.0),
                                onPressed: () {
                                  print("asd");
                                },
                              )
                          ),
                          PopupMenuItem<AddItem>(
                              value: AddItem.addRoute,
                              child: IconButton(
                                icon: const Icon(Icons.route, size: 30.0),
                                onPressed: () {
                                  print("asd");
                                },
                              )
                          ),
                          PopupMenuItem<AddItem>(
                              value: AddItem.addSpot,
                              child: IconButton(
                                icon: const Icon(Icons.location_city, size: 30.0),
                                onPressed: () {
                                  print("asd");
                                },
                              )
                          ),
                          PopupMenuItem<AddItem>(
                              value: AddItem.addTrip,
                              child: IconButton(
                                icon: const Icon(Icons.explore, size: 30.0),
                                onPressed: () {
                                  print("asd");
                                },
                              )
                          )
                        ],
                      ) // This trailing comma makes auto-formatting nicer for build methods.
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
                    floatingActionButton: PopupMenuButton<AddItem>(
                      icon: const Icon(Icons.add, size: 50.0),
                      initialValue: selectedMenu,
                      onSelected: (AddItem item) {
                        setState(() {
                          selectedMenu = item;
                        });
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<AddItem>>[
                        PopupMenuItem<AddItem>(
                            value: AddItem.addAscent,
                            child: IconButton(
                              icon: const Icon(Icons.adjust, size: 30.0),
                              tooltip: 'Ascent',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddAscent(pitches: pitches),
                                    )
                                );
                              },
                            ),
                        ),
                        PopupMenuItem<AddItem>(
                            value: AddItem.addPitch,
                            child: IconButton(
                              icon: const Icon(Icons.linear_scale, size: 30.0),
                              tooltip: 'Pitch',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddPitch(routes: routes),
                                    )
                                );
                              },
                            ),
                        ),
                        PopupMenuItem<AddItem>(
                            value: AddItem.addRoute,
                            child: IconButton(
                              icon: const Icon(Icons.route, size: 30.0),
                              tooltip: 'Route',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddRoute(spots: spots),
                                    )
                                );
                              },
                            ),
                        ),
                        PopupMenuItem<AddItem>(
                            value: AddItem.addSpot,
                            child: IconButton(
                              icon: const Icon(Icons.location_on, size: 30.0),
                              tooltip: 'Spot',
                              onPressed: () {
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
                            ),
                        ),
                        PopupMenuItem<AddItem>(
                            value: AddItem.addTrip,
                            child: IconButton(
                              icon: const Icon(Icons.explore, size: 30.0),
                              tooltip: 'Trip',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AddTrip(),
                                  )
                                );
                              },
                            ),
                        )
                      ],
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
                child: Text('You have no connection at the moment. But you can still create spots. They will be uploaded automatically as soon as you regain connection.'),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SaveLocationNoConnectionPage(onAdd: (Spot value) {})),
                  );
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
