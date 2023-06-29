import 'package:climbing_diary/components/diary_page/timeline/spot_timeline.dart';
import 'package:climbing_diary/components/list_page/spot_list.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../interfaces/spot/spot.dart';
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
    return Scaffold(
      body: FutureBuilder<List<Spot>>(
        future: spotService.getSpotsByName(controllerSearch.text),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Spot> spots = snapshot.data!;
            List<Widget> elements = [];
            elements.add(Form(
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
            ));
            elements.add(Row(
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
            ));
            elements.add( Padding(
                padding: const EdgeInsets.all(10),
                child: SpotList(
                  spots: spots
            )));
            return ListView(
              children: elements,
            );
          } else {
            return const CircularProgressIndicator();
          }
        }
      )
    );
  }
}