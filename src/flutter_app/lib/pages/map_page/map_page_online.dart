import 'package:flutter/material.dart';
import '../../components/add/add_spot.dart';
import 'spot_details.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../interfaces/spot/spot.dart';
import '../../services/spot_service.dart';

class MapPageOnline extends StatefulWidget {
  const MapPageOnline({super.key});

  @override
  State<MapPageOnline> createState() => _MapPageOnlineState();
}

class _MapPageOnlineState extends State<MapPageOnline> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controllerSearch = TextEditingController();
  final SpotService spotService = SpotService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Spot>>(
        future: spotService.getSpotsByName(controllerSearch.text, true), // TODO check if online
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
                          userAgentPackageName: 'com.example.climbing_diary',
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
  }

  getMarkers(List<Spot> spots, ValueSetter<Spot> deleteCallback, ValueSetter<Spot> updateCallback) {
    List<Marker> markers = [];
    for (var spot in spots) {
      markers.add(
        Marker(
          point: LatLng(spot.coordinates[0], spot.coordinates[1]),
          width: 30,
          height: 30,
          builder: (context) => IconButton(
            icon: const Icon(Icons.place, size: 30.0, color: Colors.pink),
            tooltip: spot.name,
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SpotDetails(
                    spot: spot,
                    onDelete: deleteCallback,
                    onUpdate: updateCallback)
              ),
            ),
          ),
        ),
      );
    }
    return markers;
  }
}
