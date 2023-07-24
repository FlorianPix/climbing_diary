import 'package:climbing_diary/pages/save_location_no_connection.dart';
import 'package:flutter/material.dart';

import 'add_spot.dart';
import 'spot_details.dart';
import '../../services/cache_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../interfaces/spot/spot.dart';
import '../../services/spot_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controllerSearch = TextEditingController();
  final SpotService spotService = SpotService();

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
            // TODO deleteQueuedSpots();
            // TODO editQueuedSpots();
            // TODO uploadQueuedSpots();
            return FutureBuilder<List<Spot>>(
              future: spotService.getSpotsByName(controllerSearch.text),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Spot> spots = snapshot.data!;

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

                  Widget search = Form(
                    key: _formKey,
                    child:
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: TextFormField(
                        controller: controllerSearch,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(25.0)),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            filled: true,
                            fillColor: Color.fromRGBO(255,127,90, .3),
                            hintText: "name",
                            labelText: "name"
                        ),
                        onChanged: (String s) {
                          setState(() {});
                        },
                      ),
                    ),
                  );

                  if (spots.isEmpty) {
                    return Scaffold(
                      body: Center(child: Stack(children: [
                        FlutterMap(
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
                        ),
                        search
                      ])),
                      floatingActionButton: FloatingActionButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddSpot(onAdd: (spot) => addSpotCallback(spot))),
                          );
                        },
                        backgroundColor: Colors.green,
                        elevation: 5,
                        child: const Icon(Icons.add, size: 50.0, color: Colors.white),
                      )
                    );
                  }

                  return Scaffold(
                    body: Center(
                      child: Stack(children: [
                        FlutterMap(
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
                      ),
                      search,
                      ]
                    )),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddSpot(onAdd: (spot) => addSpotCallback(spot)),
                          )
                        );
                      },
                      backgroundColor: Colors.green,
                      elevation: 5,
                      child: const Icon(Icons.add, size: 50.0, color: Colors.white),
                    )
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
                backgroundColor: Colors.green,
                elevation: 5,
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
