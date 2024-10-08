import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:climbing_diary/components/common/my_colors.dart';
import 'package:climbing_diary/components/add/add_spot.dart';
import 'package:climbing_diary/pages/map_page/spot_details.dart';
import 'package:climbing_diary/interfaces/spot/spot.dart';
import 'package:climbing_diary/services/spot_service.dart';

class MapPageOnline extends StatefulWidget {
  const MapPageOnline({super.key, required this.onNetworkChange});

  final ValueSetter<bool> onNetworkChange;

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
      future: spotService.getSpotsByName(controllerSearch.text),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        List<Spot> spots = snapshot.data!;

        void addSpotCallback(Spot spot) {
          spots.add(spot);
          setState(() {});
        }

        void updateSpotCallback(Spot spot) {
          var index = -1;
          for (int i = 0; i < spots.length; i++) {
            if (spots[i].id == spot.id) index = i;
          }
          spots.removeAt(index);
          spots.add(spot);
          setState(() {});
        }

        void deleteSpotCallback(Spot spot) {
          spots.remove(spot);
          setState(() {});
        }

        Widget search = Form(
          key: _formKey,
          child: Padding(
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
              onChanged: (String s) => setState(() {}),
            ),
          ),
        );

        LatLng center = LatLng(50.746036, 10.642666);

        List<Widget> flutterMapLayers = [TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'de.florian_pix.climbing_diary',
        )];

        if (spots.isNotEmpty) {
          center = LatLng(spots[0].coordinates[0], spots[0].coordinates[1]);
          flutterMapLayers.add(MarkerLayer(markers: getMarkers(
            spots,
            deleteSpotCallback,
            updateSpotCallback
          )));
        }

        return Scaffold(
          body: Center(child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(center: center, zoom: 5),
                nonRotatedChildren: [AttributionWidget.defaultWidget(
                  source: 'OpenStreetMap contributors',
                  onSourceTapped: null,
                )],
                children: flutterMapLayers,
              ),
              search,
            ]
          )),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => AddSpot(
                onAdd: (spot) => addSpotCallback(spot),
                onNetworkChange: widget.onNetworkChange
              ),
            )),
            backgroundColor: MyColors.inverse[900],
            elevation: 5,
            child: const Icon(Icons.add_rounded, size: 50.0, color: Colors.white),
          )
        );
      }
    );
  }

  List<Marker> getMarkers(List<Spot> spots, ValueSetter<Spot> deleteCallback, ValueSetter<Spot> updateCallback) {
    List<Marker> markers = [];
    for (var spot in spots) {
      markers.add(Marker(
        point: LatLng(spot.coordinates[0], spot.coordinates[1]),
        width: 30,
        height: 30,
        builder: (context) => IconButton(
          icon: const Icon(Icons.place, size: 30.0, color: Colors.pink),
          tooltip: spot.name,
          onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: SpotDetails(
                spot: spot,
                onDelete: deleteCallback,
                onUpdate: updateCallback,
                onNetworkChange: widget.onNetworkChange,
              )
            ),
          ),
        ),
      ));
    }
    return markers;
  }
}
