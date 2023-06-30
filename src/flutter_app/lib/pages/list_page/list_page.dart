import 'package:climbing_diary/interfaces/multi_pitch_route/multi_pitch_route.dart';
import 'package:climbing_diary/pages/list_page/pitch_list.dart';
import 'package:climbing_diary/pages/list_page/spot_list.dart';
import 'package:climbing_diary/pages/list_page/route_list.dart';
import 'package:climbing_diary/services/pitch_service.dart';
import 'package:flutter/material.dart';
import '../../interfaces/pitch/pitch.dart';
import '../../interfaces/single_pitch_route/single_pitch_route.dart';
import '../../interfaces/spot/spot.dart';
import '../../services/route_service.dart';
import '../../services/spot_service.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<StatefulWidget> createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controllerSearch = TextEditingController();

  final SpotService spotService = SpotService();
  final RouteService routeService = RouteService();
  final PitchService pitchService = PitchService();

  bool searchSpots = true;
  bool searchRoutes = false;
  bool searchPitches = false;

  @override
  void initState(){
    super.initState();
    searchSpots = true;
    searchRoutes = false;
    searchPitches = false;
  }

  @override
  Widget build(BuildContext context) {
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
                hintText: "name",
                labelText: "name"
            ),
            onChanged: (String s) {
              setState(() {});
            }
        ),
      ),
    );

    Widget switches = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text("spots"),
          Switch(
              value: searchSpots,
              onChanged: (bool value) {
                setState(() {
                  searchSpots = value;
                });
              }
          ),
          const Text("routes"),
          Switch(
              value: searchRoutes,
              onChanged: (bool value) {
                setState(() {
                  searchRoutes = value;
                });
              }
          ),
          const Text("pitches"),
          Switch(
              value: searchPitches,
              onChanged: (bool value) {
                setState(() {
                  searchPitches = value;
                });
              }
          ),
        ]
    );

    Widget spotList = FutureBuilder<List<Spot>>(
        future: spotService.getSpotsByName(controllerSearch.text),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Spot> spots = snapshot.data!;
            return SpotList(
              spots: spots
            );
          } else {
            return const CircularProgressIndicator();
          }
        }
    );

    Widget routeList = FutureBuilder<List<MultiPitchRoute>>(
        future: routeService.getMultiPitchRoutesByName(controllerSearch.text),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<MultiPitchRoute> multiPitchRoutes = snapshot.data!;
            return FutureBuilder<List<SinglePitchRoute>>(
                future: routeService.getSinglePitchRoutesByName(controllerSearch.text),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<SinglePitchRoute> singlePitchRoutes = snapshot.data!;
                    return RouteList(
                      singlePitchRoutes: singlePitchRoutes,
                      multiPitchRoutes: multiPitchRoutes,
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                }
            );
          } else {
            return const CircularProgressIndicator();
          }
        }
    );

    Widget pitchList = FutureBuilder<List<Pitch>>(
        future: pitchService.getPitchesByName(controllerSearch.text),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Pitch> pitches = snapshot.data!;
            return PitchList(
                pitches: pitches
            );
          } else {
            return const CircularProgressIndicator();
          }
        }
    );

    List<Widget> elements = [];

    if (searchSpots){
      elements.add(spotList);
    }
    if(searchRoutes){
      elements.add(routeList);
    }
    if(searchPitches){
      elements.add(pitchList);
    }

    return Scaffold(
      body: Column(children: [search, switches, Expanded(child: ListView(children: elements))])
    );
  }
}